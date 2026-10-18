import { getStore, getDeployStore } from '@netlify/blobs';
import { createCollector } from '../../lib/campaign-events.js';

export default createCollector(context => context.deploy?.context === 'production'
  ? getStore({ name: 'notchdock-campaign-production-v1', consistency: 'strong' })
  : getDeployStore('notchdock-campaign-preview-v1'));

export const config = {
  path: '/api/campaign-events',
  rateLimit: { windowLimit: 120, windowSize: 60, aggregateBy: ['ip'] },
};
