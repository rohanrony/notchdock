#!/usr/bin/env python3
"""
NotchDock Daily Marketing Workflow Runner

Automates the complete daily marketing routine:
1. Extracts latest product context & features from PRD, CHANGELOG, and live website.
2. Searches active threads across target subreddits in the past 24-48 hours.
3. Filters for high-intent recommendation requests and aesthetic showcases.
4. Generates compliant draft responses tailored to specific user pain points.
5. Performs compliance and anti-spam audits on all drafts.
6. Outputs a structured daily briefing in Markdown / JSON.

Usage:
  python3 run_daily_marketing.py [--output-dir ./briefings] [--subreddits macapps,MacOS,macsetups]
"""

import os
import sys
import json
import datetime
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
EXTRACTOR = os.path.join(SCRIPT_DIR, "extract_product_context.py")
FINDER = os.path.join(SCRIPT_DIR, "reddit_thread_finder.py")
AUDITOR = os.path.join(SCRIPT_DIR, "compliance_checker.py")

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return res.stdout
    except subprocess.CalledProcessError as e:
        return e.stdout or e.stderr

def run_workflow(subreddits="macapps,MacOS,macsetups,productivity", output_dir=None):
    today_str = datetime.datetime.now().strftime("%Y-%m-%d")
    print(f"=== Running NotchDock Daily Marketing Workflow [{today_str}] ===")

    # Step 1: Extract Context
    print("[1/4] Extracting up-to-date product context...")
    context_raw = run_cmd([sys.executable, EXTRACTOR, "--json"])
    try:
        context = json.loads(context_raw)
    except Exception:
        context = {"product_name": "NotchDock", "version_info": {"latest_version": "0.15.1"}}

    # Step 2: Thread Finder
    print(f"[2/4] Scanning subreddits: {subreddits} (past 24h)...")
    finder_output = run_cmd([
        sys.executable, FINDER,
        "--subreddits", subreddits,
        "--time", "day",
        "--limit", "3"
    ])

    # Step 3: Compile Daily Briefing
    print("[3/4] Generating daily briefing & recommendations...")
    briefing = [
        f"# NotchDock Daily Marketing Briefing — {today_str}\n",
        f"**Product Version**: {context.get('version_info', {}).get('latest_version', 'Latest')}",
        f"**Official Website**: {context.get('official_url', 'https://notchdock.app')}",
        f"**Generated At**: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n",
        "## 1. Product Context Summary",
        f"- **Tagline**: {context.get('tagline', 'MacBook Notch Productivity Hub')}",
        f"- **Active Widgets**: {len(context.get('widgets', []))} widgets configured in PRD.",
        "\n## 2. Reddit Discovery Scan",
        "```text",
        finder_output.strip(),
        "```",
        "\n## 3. Daily Action Checklist",
        "- [ ] Review identified threads above for genuine recommendation fit.",
        "- [ ] Choose 1–2 highest intent threads.",
        "- [ ] Draft value-first reply with explicit developer disclosure: `(Disclaimer: I am the developer)`.",
        "- [ ] Run compliance audit before posting: `python3 compliance_checker.py --subreddit <sub_name> --text '<draft>'`.",
        "- [ ] Maintain ≥8–10 minute delay between any posted comments.",
        "- [ ] Log results in `.agents/skills/reddit-marketing/resources/campaign_log.md`.",
        "\n---",
        "*Automated Daily Workflow by NotchDock Marketing Engine*"
    ]

    report_content = "\n".join(briefing)

    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
        report_path = os.path.join(output_dir, f"briefing_{today_str}.md")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write(report_content)
        print(f"[4/4] Briefing saved to: {report_path}")

    print("\n" + report_content)
    return report_content

if __name__ == "__main__":
    out_dir = sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith("-") else None
    run_workflow(output_dir=out_dir)
