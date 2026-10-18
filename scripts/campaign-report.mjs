import { getStore } from '@netlify/blobs';
import { readFile } from 'node:fs/promises';
import { aggregateEvents } from '../lib/campaign-events.js';

const fixture = process.argv.indexOf('--input');
let records;
if (fixture >= 0) {
  const inputPath = process.argv[fixture + 1];
  if (!inputPath || inputPath.startsWith('--')) {
    console.error('Usage: npm run marketing:report -- --input <events.json>');
    process.exit(1);
  }
  let input;
  try {
    input = await readFile(inputPath, 'utf8');
  } catch (error) {
    console.error(`Could not read local export: ${error.code ?? error.message}`);
    process.exit(1);
  }
  try {
    records = JSON.parse(input);
  } catch {
    console.error('Invalid JSON in local export. Expected an events.json array.');
    process.exit(1);
  }
  if (!Array.isArray(records)) {
    console.error('Invalid local export. Expected an events.json array.');
    process.exit(1);
  }
} else {
  if (!process.env.NETLIFY_SITE_ID || !process.env.NETLIFY_AUTH_TOKEN) {
    console.error('Set NETLIFY_SITE_ID and NETLIFY_AUTH_TOKEN in your shell, or use --input <local-export.json>. Do not commit credentials.');
    process.exit(1);
  }
  const store = getStore({ name: 'notchdock-campaign-production-v1', siteID: process.env.NETLIFY_SITE_ID, token: process.env.NETLIFY_AUTH_TOKEN, consistency: 'strong' });
  records = [];
  for await (const page of store.list({ prefix: 'v1/', paginate: true })) {
    for (let offset = 0; offset < page.blobs.length; offset += 20) {
      const batch = await Promise.all(page.blobs.slice(offset, offset + 20).map(blob => store.get(blob.key, { type: 'json' })));
      records.push(...batch.filter(Boolean));
    }
  }
}
const deviceTypes = new Set(['mac', 'mobile', 'other', 'unknown']);
const stringFields = ['day', 'source', 'medium', 'campaign', 'placement', 'landing'];
for (const [index, record] of records.entries()) {
  const prefix = `Invalid event record at index ${index}:`;
  if (!record || typeof record !== 'object' || Array.isArray(record)) {
    console.error(`${prefix} expected an object.`);
    process.exit(1);
  }
  if (!['session', 'download'].includes(record.event)) {
    console.error(`${prefix} event must be session or download.`);
    process.exit(1);
  }
  for (const field of stringFields) {
    if (typeof record[field] !== 'string') {
      console.error(`${prefix} ${field} must be a string.`);
      process.exit(1);
    }
  }
  if (!deviceTypes.has(record.device)) {
    console.error(`${prefix} device must be mac, mobile, other, or unknown.`);
    process.exit(1);
  }
}
const diagnostics = records.filter(record => record.campaign === 'nd30_preview' || record.campaign.startsWith('nd30_diagnostic'));
const measured = records.filter(record => !diagnostics.includes(record));
console.log(JSON.stringify({ excluded_diagnostic_records: diagnostics.length, generated_at: new Date().toISOString(), units: '30-minute browser sessions; CTA sessions are not completed downloads or users', rows: aggregateEvents(measured) }, null, 2));
