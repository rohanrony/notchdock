# Growth implementation

The site now has a workflow-led homepage, sports/focus destinations, a real recorded sports clip and corrected compatibility/claim copy. This change does not alter the native Mac app.

## Website analytics

`campaign-analytics.js` sends one short-lived browser-session identity and only a session/download event to `/api/campaign-events`. IDs expire after 30 minutes; source labels are frozen at the first landing. Full queries, referrer paths and application content are excluded. Do Not Track and Global Privacy Control disable collection. The client does not block navigation for measurement.

The Netlify function writes separate deterministic keys in Netlify Blobs and reads each back before acknowledging success. Multiple CTA clicks are deduplicated. A CTA also inserts its session if the first request was lost. Production uses `notchdock-campaign-production-v1`; previews use a deploy-scoped store and cannot write production data. There is no public analytics read endpoint.

The retention function deletes expired records daily after 30 days. Its scheduled job is retention maintenance, not telemetry polling. This configuration becomes active only when deployed to Netlify. Existing Netlify usage limits apply; no paid plan or external analytics account was enabled.

Read the report with `npm run marketing:report` after providing `NETLIFY_SITE_ID` and `NETLIFY_AUTH_TOKEN` in the local shell. Do not put credentials in source or expose them to the browser. For a local export, use `npm run marketing:report -- --input <events.json>`. Empty/partial data cannot prove that a channel produced no traffic. Counts are browser sessions and CTA sessions, not people, successful downloads or app usage.

## Validate and release

Run `npm run test:marketing` and `npm run build`. Inspect homepage and both workflow pages on desktop/mobile, then a tagged local visit and CTA with a local collector. Netlify deployment must include functions, not only the static `dist` directory. After deployment, verify one excluded diagnostic visit through Netlify's authenticated Blobs read-back before claiming central reporting is live.

The sports MP4 comes from the supplied sports GIF. The focus image/video is a clearly labelled still preview; it does not demonstrate an actual countdown. The full original walkthrough was not found as an MP4/MOV in the inspected asset directories, so more action cuts still need the master or a new native recording. Do not copy the old chapter list.
