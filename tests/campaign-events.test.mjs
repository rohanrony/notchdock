import test from 'node:test';
import assert from 'node:assert/strict';
import { createCollector, aggregateEvents, normalizeEvent, pruneEvents } from '../lib/campaign-events.js';
import { landingAttribution, initCampaignAnalytics } from '../campaign-analytics.js';

const now = Date.parse('2026-10-18T06:00:00Z');
const payload = { id: '76a29ff4-e6c7-41f5-97b7-228023a3a720', started: now - 1000, event: 'session', device: 'mac', source: 'reddit_macos', medium: 'community', campaign: 'nd30_test', placement: 'sports_c1', landing: '/features/mac-sports-tracker.html' };
function memoryStore() {
  const values = new Map();
  return { values,
    async setJSON(key, value, options = {}) { if (!options.onlyIfNew || !values.has(key)) values.set(key, value); },
    async get(key) { return values.get(key) || null; },
    async *list() { const keys = [...values.keys()]; for (let i = 0; i < keys.length; i += 2) yield { blobs: keys.slice(i, i + 2).map(key => ({ key })) }; },
    async delete(key) { values.delete(key); },
  };
}
const request = (data, origin = 'https://notchdock.app') => new Request('https://notchdock.app/api/campaign-events', { method: 'POST', headers: { Origin: origin, 'Content-Type': 'application/json' }, body: JSON.stringify(data) });

test('repeated/concurrent CTA clicks persist one landing session and one CTA session', async () => {
  const store = memoryStore(); const collect = createCollector(() => store, () => now);
  const responses = await Promise.all([collect(request(payload)), ...Array.from({ length: 4 }, () => collect(request({ ...payload, event: 'download' })))]);
  assert.ok(responses.every(response => response.status === 200));
  const rows = aggregateEvents([...store.values.values()]);
  assert.equal(rows.length, 1); assert.equal(rows[0].sessions, 1); assert.equal(rows[0].download_cta_sessions, 1);
});

test('a lost initial landing request does not leave a CTA without its session', async () => {
  const store = memoryStore(); const collect = createCollector(() => store, () => now);
  assert.equal((await collect(request({ ...payload, event: 'download' }))).status, 200);
  assert.equal(store.values.size, 2);
});

test('collector rejects other origins, stale sessions and personal/query payloads', async () => {
  const store = memoryStore(); const collect = createCollector(() => store, () => now);
  assert.equal((await collect(request(payload, 'https://elsewhere.example'))).status, 403);
  assert.equal((await collect(request({ ...payload, started: now - 3600000 }))).status, 400);
  assert.equal((await collect(request({ ...payload, source: 'person@example.com' }))).status, 400);
  assert.equal((await collect(request({ ...payload, landing: '/?private=note' }))).status, 400);
  const normalized = normalizeEvent({ ...payload, note: 'private' }, now);
  assert.equal('note' in normalized, false); assert.equal('id' in normalized, false);
  assert.equal(store.values.size, 0);
});

test('failed storage or missing read-back is unavailable, never false success', async () => {
  const failed = createCollector(() => ({ setJSON: async () => { throw new Error('Unavailable'); } }), () => now);
  assert.equal((await failed(request(payload))).status, 503);
  const lost = createCollector(() => ({ setJSON: async () => {}, get: async () => null }), () => now);
  assert.equal((await lost(request(payload))).status, 503);
});

test('retention walks every page and removes only expired campaign records', async () => {
  const store = memoryStore();
  for (const key of ['v1/2026-08-01/a/session','v1/2026-09-01/a/session','v1/2026-10-18/a/session','unknown/key']) store.values.set(key, {});
  assert.equal(await pruneEvents(store, now), 2);
  assert.deepEqual([...store.values.keys()], ['v1/2026-10-18/a/session','unknown/key']);
});

test('attribution excludes queries and referrer paths; tagged placement survives as labels', () => {
  const location = new URL('https://notchdock.app/features/mac-sports-tracker.html?utm_source=reddit_macos&utm_content=sports_c1&secret=private');
  const attribution = landingAttribution(location, 'https://reddit.com/private/path?secret=note');
  assert.equal(attribution.source, 'reddit_macos'); assert.equal(attribution.placement, 'sports_c1');
  assert.equal(attribution.landing, '/features/mac-sports-tracker.html');
  assert.equal(JSON.stringify(attribution).includes('private'), false);
});

test('frontend respects privacy signals and leaves normal navigation untouched', async () => {
  let listener; const calls = [];
  const win = { navigator: { platform: 'MacIntel', userAgent: 'Chrome', maxTouchPoints: 0 }, location: new URL('https://notchdock.app/?utm_source=reddit_macos'), crypto: { randomUUID: () => payload.id }, sessionStorage: { getItem: () => null, setItem: () => {} }, fetch: async (_url, options) => { calls.push(JSON.parse(options.body)); return { ok: true }; } };
  const doc = { referrer: '', addEventListener: (_name, fn) => { listener = fn; } };
  initCampaignAnalytics({ ...win, navigator: { ...win.navigator, globalPrivacyControl: true } }, doc);
  assert.equal(calls.length, 0);
  initCampaignAnalytics(win, doc);
  listener({ target: { closest: () => ({ href: 'https://github.com/rohanrony/notchdock/releases/latest/download/NotchDock.dmg' }) } });
  assert.deepEqual(calls.map(call => call.event), ['session','download']);
});
