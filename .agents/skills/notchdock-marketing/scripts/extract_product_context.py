#!/usr/bin/env python3
"""
Extracts up-to-date product context, features, widgets, pricing, and messaging
for NotchDock by reading local repository files (PRD.md, CHANGELOG.md, Settings)
and querying the live website.

Outputs a normalized JSON or Markdown summary so marketing skills never go stale.
"""

import os
import sys
import json
import re
import urllib.request
import urllib.error

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../../"))

def extract_prd_info(repo_root):
    prd_path = os.path.join(repo_root, "PRD.md")
    if not os.path.exists(prd_path):
        return {"error": "PRD.md not found"}
    
    with open(prd_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract widgets
    widgets = []
    widget_matches = re.findall(r"### \d+\.\d+\s+([^\n]+)\n(.*?)(?=\n###|\n---|\Z)", content, re.DOTALL)
    for title, body in widget_matches:
        func_match = re.search(r"-\s+\*\*Function\*\*:\s*([^\n]+)", body)
        cap_match = re.search(r"-\s+\*\*Key Capability\*\*:\s*([^\n]+)", body)
        widgets.append({
            "name": title.strip(),
            "function": func_match.group(1).strip() if func_match else "",
            "key_capability": cap_match.group(1).strip() if cap_match else body.strip().split("\n")[0]
        })

    # Extract executive summary & vision
    summary_match = re.search(r"### 1\.1 Executive Summary\n\*\*NotchDock\*\*\s*([^\n]+)", content)
    vision_match = re.search(r"### 1\.2 Vision\n([^\n]+)", content)

    return {
        "summary": summary_match.group(1).strip() if summary_match else "",
        "vision": vision_match.group(1).strip() if vision_match else "",
        "widgets": widgets
    }

def extract_latest_changelog(repo_root):
    changelog_path = os.path.join(repo_root, "CHANGELOG.md")
    if not os.path.exists(changelog_path):
        return {"latest_version": "Unknown", "recent_changes": []}

    with open(changelog_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    latest_version = "Unknown"
    recent_changes = []
    in_latest_section = False

    for line in lines:
        if line.startswith("## ["):
            if not in_latest_section:
                in_latest_section = True
                latest_version = line.strip().lstrip("# ").strip()
            else:
                break
        elif in_latest_section and line.strip().startswith("- **"):
            recent_changes.append(line.strip().lstrip("- "))

    return {
        "latest_version": latest_version,
        "recent_highlights": recent_changes[:8]
    }

def fetch_website_metadata(url="https://notchdock.app"):
    try:
        import ssl
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"})
        with urllib.request.urlopen(req, timeout=5, context=ctx) as response:
            html = response.read().decode("utf-8")
            
            title_match = re.search(r"<title>(.*?)</title>", html, re.IGNORECASE)
            desc_match = re.search(r'<meta\s+name=["\']description["\']\s+content=["\'](.*?)["\']', html, re.IGNORECASE)
            
            return {
                "url": url,
                "title": title_match.group(1) if title_match else "NotchDock",
                "meta_description": desc_match.group(1) if desc_match else "",
                "status": "online"
            }
    except Exception as e:
        return {
            "url": url,
            "status": "offline_or_error",
            "error": str(e)
        }

def generate_context_bundle():
    prd_data = extract_prd_info(REPO_ROOT)
    changelog_data = extract_latest_changelog(REPO_ROOT)
    website_data = fetch_website_metadata()

    bundle = {
        "product_name": "NotchDock",
        "tagline": "Turn your MacBook Notch into a Dynamic Island & Productivity Hub",
        "official_url": "https://notchdock.app",
        "download_url": "https://github.com/rohanrony/notchdock/releases/",
        "platform": "macOS (Apple Silicon M-series with Notch & external displays)",
        "architecture": "Swift 6, SwiftUI, 100% Local-only & sandboxed",
        "pricing_summary": "Free to try / Lifetime purchase available",
        "website_status": website_data,
        "version_info": changelog_data,
        "widgets": prd_data.get("widgets", []),
        "core_value_props": [
            "Glanceable micro-productivity right under the physical hardware notch",
            "Zero context-switching: Join meetings, take notes, or check scores without opening full apps",
            "100% local and private: No telemetry, no cloud backend, zero trackers",
            "Lightweight: <1% idle CPU footprint and instant hover expand/collapse"
        ]
    }
    return bundle

if __name__ == "__main__":
    context = generate_context_bundle()
    if "--json" in sys.argv or len(sys.argv) == 1:
        print(json.dumps(context, indent=2))
    elif "--markdown" in sys.argv:
        print(f"# Product Context: {context['product_name']}\n")
        print(f"**Tagline**: {context['tagline']}")
        print(f"**Version**: {context['version_info']['latest_version']}")
        print(f"**Website**: {context['official_url']}\n")
        print("## Core Widgets")
        for w in context['widgets']:
            print(f"- **{w['name']}**: {w.get('key_capability') or w.get('function')}")
        print("\n## Recent Highlights")
        for h in context['version_info']['recent_highlights']:
            print(f"- {h}")
