#!/usr/bin/env python3
"""
Compliance & Quality Checker for Reddit Comments and Posts

Audits drafted marketing text against subreddit-specific rules, developer disclosure
requirements, anti-spam heuristics, and formatting requirements (e.g. PCP for r/macapps).

Usage:
  python3 compliance_checker.py --subreddit macapps --text "Draft comment..."
  python3 compliance_checker.py --file path/to/draft.md --subreddit MacOS
"""

import sys
import os
import re
import argparse

DISCLOSURE_PATTERNS = [
    r"i am the developer",
    r"i built this",
    r"i created this",
    r"full disclosure",
    r"disclaimer:",
    r"dev here",
    r"i'm the dev",
    r"author of"
]

PCP_SECTIONS = [
    (r"problem", "Problem section"),
    (r"comparison", "Comparison section"),
    (r"pricing", "Pricing section")
]

def audit_comment(text, subreddit):
    sub = subreddit.lower().replace("r/", "")
    issues = []
    warnings = []
    passes = []

    # 1. Developer Disclosure Check
    has_disclosure = any(re.search(pat, text, re.IGNORECASE) for pat in DISCLOSURE_PATTERNS)
    if has_disclosure:
        passes.append("Developer disclosure detected (avoids astroturfing violations).")
    else:
        if sub in ["macapps", "macos", "apple", "productivity"]:
            issues.append("MISSING DISCLOSURE: Explicit developer disclosure required for this subreddit.")
        else:
            warnings.append("No developer disclosure found. Highly recommended to prevent spam reports.")

    # 2. Subreddit Specific Formatting
    if sub == "macapps":
        # Check PCP format if standalone post or long-form review
        is_standalone = len(text.splitlines()) > 5 or "#" in text
        if is_standalone:
            for pat, name in PCP_SECTIONS:
                if not re.search(pat, text, re.IGNORECASE):
                    warnings.append(f"r/macapps PCP standard: Missing '{name}'.")
                else:
                    passes.append(f"PCP structure: '{name}' detected.")

    # 3. URL Quality & Density Check
    urls = re.findall(r"https?://[^\s\)]+", text)
    if len(urls) > 2:
        warnings.append(f"HIGH LINK DENSITY: {len(urls)} links found. High link counts trigger Reddit AutoMod filters.")
    elif len(urls) == 0:
        passes.append("No links: Safest format for building karma or conversational replies.")
    else:
        for u in urls:
            if "notchdock.app" in u or "github.com/rohanrony" in u:
                passes.append(f"Clean official link: {u}")
            else:
                warnings.append(f"Third-party link: {u}")

    # 4. Marketing Language & Clichés Check
    spammy_terms = ["best in the world", "unbelievable", "revolutionary", "game-changer", "act now", "limited time"]
    for term in spammy_terms:
        if term in text.lower():
            warnings.append(f"Spam trigger word detected: '{term}'. Rewrite in organic, authentic voice.")

    # 5. Length & Formatting
    word_count = len(text.split())
    if word_count < 15:
        warnings.append("Comment is very brief (<15 words). Ensure it adds genuine value before linking.")
    elif word_count > 350:
        warnings.append("Comment is long (>350 words). For recommendation threads, keep it scannable.")
    else:
        passes.append(f"Good comment length ({word_count} words).")

    return {
        "subreddit": f"r/{sub}",
        "status": "FAIL" if issues else ("WARN" if warnings else "PASS"),
        "issues": issues,
        "warnings": warnings,
        "passes": passes
    }

def main():
    parser = argparse.ArgumentParser(description="Audit Reddit marketing copy for compliance")
    parser.add_argument("--subreddit", type=str, required=True, help="Target subreddit (e.g. macapps, MacOS)")
    parser.add_argument("--text", type=str, default="", help="Text string to audit")
    parser.add_argument("--file", type=str, default="", help="Path to markdown/text file to audit")
    args = parser.parse_args()

    content = args.text
    if args.file and os.path.exists(args.file):
        with open(args.file, "r", encoding="utf-8") as f:
            content = f.read()

    if not content:
        print("[!] Error: Provide either --text or --file")
        sys.exit(1)

    result = audit_comment(content, args.subreddit)
    print(f"=== Compliance Audit: {result['subreddit']} ===")
    print(f"Result: {result['status']}\n")

    if result["passes"]:
        print("[+] Passed Checks:")
        for p in result["passes"]:
            print(f"    ✓ {p}")

    if result["warnings"]:
        print("\n[?] Warnings / Recommendations:")
        for w in result["warnings"]:
            print(f"    ! {w}")

    if result["issues"]:
        print("\n[-] Critical Violations:")
        for i in result["issues"]:
            print(f"    ✗ {i}")

    sys.exit(1 if result["issues"] else 0)

if __name__ == "__main__":
    main()
