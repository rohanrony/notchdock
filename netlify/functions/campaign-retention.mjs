import { getStore } from '@netlify/blobs';
import { pruneEvents } from '../../lib/campaign-events.js';

export default async (_request, context) => {
  if (context.deploy?.context !== 'production') return new Response('Preview: no production cleanup');
  const deleted = await pruneEvents(getStore('notchdock-campaign-production-v1'));
  return new Response(JSON.stringify({ deleted }), { headers: { 'Content-Type': 'application/json' } });
};

// Retention maintenance only; this does not poll downloads or platform metrics.
export const config = { schedule: '17 3 * * *' };
