import { createHash } from 'node:crypto';

const headers = { 'Cache-Control': 'no-store', 'Content-Type': 'application/json' };
const reply = (status, value) => new Response(JSON.stringify(value), { status, headers });
const slug = value => typeof value === 'string' && /^[a-z0-9_-]{0,64}$/i.test(value);

export function normalizeEvent(input, now = Date.now()) {
  if (!input || !['session', 'download'].includes(input.event)) throw new Error('Invalid event');
  if (typeof input.id !== 'string' || !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(input.id)) throw new Error('Invalid session');
  if (!Number.isSafeInteger(input.started) || input.started > now + 60000 || now - input.started > 31 * 60000) throw new Error('Expired session');
  if (!['mac', 'mobile', 'other', 'unknown'].includes(input.device)) throw new Error('Invalid device');
  for (const field of ['source', 'medium', 'campaign', 'placement']) if (!slug(input[field])) throw new Error('Invalid source label');
  if (typeof input.landing !== 'string' || input.landing.length > 160 || !/^\/[a-z0-9/_-]*(?:\.html)?$/i.test(input.landing)) throw new Error('Invalid landing');
  return {
    session: createHash('sha256').update(input.id).digest('hex'),
    day: new Date(input.started).toISOString().slice(0, 10),
    event: input.event, device: input.device, source: input.source || 'direct',
    medium: input.medium, campaign: input.campaign, placement: input.placement,
    landing: input.landing,
  };
}

export function createCollector(storeFor, now = () => Date.now()) {
  return async (request, context = {}) => {
    if (request.method !== 'POST') return reply(405, { error: 'POST required' });
    if (request.headers.get('Origin') !== new URL(request.url).origin) return reply(403, { error: 'Same-origin request required' });
    if (!request.headers.get('Content-Type')?.startsWith('application/json')) return reply(415, { error: 'JSON required' });
    let event;
    try {
      const raw = await request.text();
      if (raw.length > 2048) return reply(413, { error: 'Payload too large' });
      event = normalizeEvent(JSON.parse(raw), now());
    } catch { return reply(400, { error: 'Invalid event payload' }); }
    try {
      const store = storeFor(context);
      const common = { device: event.device, source: event.source, medium: event.medium, campaign: event.campaign, placement: event.placement, landing: event.landing, day: event.day };
      // Each event has its own key: no shared counters, read-modify-write races or double-click inflation.
      // A CTA also records its landing session if its initial network request was lost.
      for (const kind of event.event === 'download' ? ['session', 'download'] : ['session']) {
        const key = `v1/${event.day}/${event.session}/${kind}`;
        const record = { ...common, event: kind, received_at: new Date(now()).toISOString() };
        await store.setJSON(key, record, { onlyIfNew: true, metadata: record });
        const saved = await store.get(key, { type: 'json', consistency: 'strong' });
        if (!saved || saved.event !== kind || saved.day !== event.day) throw new Error('Storage read-back failed');
      }
      return reply(200, { recorded: true });
    } catch { return reply(503, { recorded: false }); }
  };
}

export async function pruneEvents(store, now = Date.now()) {
  const cutoff = new Date(now - 30 * 86400000).toISOString().slice(0, 10);
  let deleted = 0;
  for await (const page of store.list({ prefix: 'v1/', paginate: true })) {
    const expired = page.blobs.filter(blob => /^v1\/\d{4}-\d{2}-\d{2}\//.test(blob.key) && blob.key.split('/')[1] < cutoff);
    for (let offset = 0; offset < expired.length; offset += 20) {
      await Promise.all(expired.slice(offset, offset + 20).map(blob => store.delete(blob.key)));
      deleted += expired.slice(offset, offset + 20).length;
    }
  }
  return deleted;
}

export function aggregateEvents(records) {
  const groups = new Map();
  for (const record of records) {
    const key = JSON.stringify([record.day, record.source, record.medium, record.campaign, record.placement, record.landing, record.device]);
    const row = groups.get(key) || { day: record.day, source: record.source, medium: record.medium, campaign: record.campaign, placement: record.placement, landing: record.landing, device: record.device, sessions: 0, download_cta_sessions: 0 };
    if (record.event === 'session') row.sessions++;
    if (record.event === 'download') row.download_cta_sessions++;
    groups.set(key, row);
  }
  return [...groups.values()].sort((a, b) => b.day.localeCompare(a.day) || b.download_cta_sessions - a.download_cta_sessions);
}
