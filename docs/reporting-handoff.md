# NotchDock reporting handoff

Updated 2026-10-18. This is an operator procedure for reading existing reports. It does not start the 30-day campaign, change collection, or create a new service.

## Current readiness

- The production collector has returned `200` with `recorded: true` for diagnostic events after a strong storage read-back. The production store is `notchdock-campaign-production-v1`; preview and diagnostic campaigns are excluded from campaign totals. These are collector checks, not real visitor conversions.
- The aggregate report has not been read. In the current operator shell, `NETLIFY_SITE_ID` and `NETLIFY_AUTH_TOKEN` are absent, and the Netlify CLI is unavailable. A local browser-profile lockfile exists, but there is no verified browser session to use. Do not delete it, launch or claim the profile, or retrieve credentials from browser storage.
- No Search Console performance export or property access was available. Do not infer search impressions, clicks, queries, pages, CTR, or indexing from a verification token or an SEO audit.
- There are no recorded consenting tester outcomes in the reporting handoff. Campaign start, end, and baseline remain unset.

## Read the authenticated website report

An administrator who already has authorized access should configure these environment variables in a private local shell or approved secret manager, without placing values in source, chat, shell history, logs, or browser code:

- `NETLIFY_SITE_ID`
- `NETLIFY_AUTH_TOKEN`

From the website repository, run:

```sh
npm run marketing:report
```

The command reads `notchdock-campaign-production-v1` using paginated listing and batched reads. Save the JSON output to a restricted local location if it needs to be retained. Do not commit production records or credential values.

For an already-authorized export, run:

```sh
npm run marketing:report -- --input /path/to/events.json
```

The local export must be a JSON array of persisted event objects: `event` is `session` or `download`; `day`, `source`, `medium`, `campaign`, `placement`, and `landing` are strings; and `device` is `mac`, `mobile`, `other`, or `unknown`. The raw session identifier is intentionally absent from persisted records. Invalid rows fail with their array index before aggregation. The report excludes `nd30_preview` and campaigns whose names start with `nd30_diagnostic`. It groups by day, source, medium, campaign, placement, landing path, and coarse device. Its units are 30-minute browser sessions and sessions with a download CTA event. A CTA is not proof that a download completed, a person installed the app, or the app was used. The collector's 30-day expiry also limits how far back a later read can see.

Read the report output back and record its generation time, covered days, empty/partial-data caveats, diagnostic exclusions, and totals by event. Compare its site CTA sessions with static and versioned GitHub request deltas as separate measures. GitHub request deltas are route requests, not unique users, completed installs, or campaign attribution. Never turn an empty report into evidence of zero traffic.

## Search Console export

Use the owner-authorized Google Search Console account for the verified `https://notchdock.app/` property. If that property is not visible to the operator, stop and ask the property owner/admin to provide access through Google's normal access controls; do not ask them to paste tokens or credentials.

1. Open **Performance → Search results** and select **Web** search type.
2. Select the last 28 complete days and compare them with the preceding 28-day period. Save the exact date boundaries and the report's last-updated date. Avoid treating preliminary recent data as final.
3. With **Pages** selected, keep clicks, impressions, average CTR, and average position visible and export the current report view.
4. Repeat with **Queries** selected under the same date comparison and export that view separately. Page and query tables are distinct views. Keep the property totals from the chart/report separate from the exported row sums: exports are limited to rows shown, and Search Console can omit anonymized queries or truncate examples.
5. Label the files with the property, search type, dimension, exact compared date ranges, export time, and whether it is Web search. Store them in the approved private reporting location, not this repository.

Use the export to identify which real queries and landing pages earn impressions and clicks, and where CTR may merit a snippet/result review. Low CTR alone does not diagnose a copy or ranking problem; inspect the actual query, page, search result context, device/country filters if relevant, and sample size. Search clicks are not website sessions or downloads.

For indexing diagnosis, open **Indexing → Pages** for the overall known-URL status and investigate specific important canonical pages with **URL Inspection** (for example, the homepage and published sports/focus pages). Record the inspected URL, Google's selected canonical, last crawl/index state, and any issue. A URL shown as indexed is eligible to appear, not guaranteed to appear for a query. A live inspection tests the current page and is distinct from the stored indexed view. The Page indexing report is a coverage overview, not a complete census of every possible URL; duplicate/non-canonical URLs need not be indexed.

Official Google instructions: [Search results Performance report](https://support.google.com/webmasters/answer/7576553), [filters and comparisons](https://support.google.com/webmasters/answer/17011165), [export limits](https://support.google.com/webmasters/answer/12919797), [Page indexing](https://support.google.com/webmasters/answer/7440203), and [URL Inspection](https://support.google.com/webmasters/answer/9012289).

## Source-tag contract

For each eligible external placement, give the exact destination a stable placement identifier and UTM tags. Example shape:

```text
https://notchdock.app/features/mac-sports-tracker.html?utm_source=macos_reddit&utm_medium=community&utm_campaign=nd30_<start_id>&utm_content=r_macapps_sports_a
```

Use lowercase letters, digits, underscores, or hyphens in values. `utm_campaign` must use the actual campaign identifier frozen at authorized start; do not use this example literally. Use one `utm_content` value per external object. Keep the canonical destination path useful if tags are stripped. Never put names, emails, private notes, or other personal data in UTM values. Untagged or stripped links remain unattributed/unknown; do not backfill attribution from timing alone.

## Report each channel independently

- **Owned website collector:** sessions and download-CTA sessions, with covered dates, source-tagged and unknown traffic separated.
- **GitHub releases:** static DMG requests and versioned DMG requests reported separately over matched snapshots; neither proves unique downloads, installs, or use.
- **Search Console:** Web clicks, impressions, CTR, and average position by date, page, and query exports; these are search-result measures, not sessions or conversions.
- **Tester panel:** explicit consent, observed first task, follow-up eligibility, distinct use days, response/nonresponse, and unknown outcomes. Do not identify testers in a public repository.
- **Publication receipts:** exact public URLs and verified public state, separate from drafts, sends, pending submissions, or accepted-but-unpublished items.

A campaign report is ready only after the admin read-back, date coverage and baseline are recorded, current Search Console exports are available or explicitly marked inaccessible, and tester outcomes are based on actual consenting participants. Until then report the relevant input as blocked/unknown; do not manufacture aggregate metrics or infer a campaign start.
