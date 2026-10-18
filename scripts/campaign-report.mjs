import { getStore } from '@netlify/blobs';
import { readFile } from 'node:fs/promises';
import { aggregateEvents } from '../lib/campaign-events.js';

const fixture = process.argv.indexOf('--input');
let records;
if (fixture >= 0) records = JSON.parse(await readFile(process.argv[fixture + 1], 'utf8'));
else {
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
const diagnostics = records.filter(record => record.campaign === 'nd30_preview' || record.campaign?.startsWith('nd30_diagnostic'));
const measured = records.filter(record => !diagnostics.includes(record));
console.log(JSON.stringify({ excluded_diagnostic_records: diagnostics.length, generated_at: new Date().toISOString(), units: '30-minute browser sessions; CTA sessions are not completed downloads or users', rows: aggregateEvents(measured) }, null, 2));
