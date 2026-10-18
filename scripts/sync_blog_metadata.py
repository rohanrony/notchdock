#!/usr/bin/env python3
"""Synchronize discovery metadata from existing, reviewed HTML; never generate articles."""
import argparse
from datetime import datetime, timezone
from html import escape, unescape
from html.parser import HTMLParser
import json
import math
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
DOMAIN = "https://notchdock.app"


class ArticleParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.title = []
        self.heading = []
        self.meta = {}
        self.canonical = []
        self.schemas = []
        self.body = []
        self.current = None
        self.article_depth = 0
        self.h1_count = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag in ("title", "h1"):
            self.current = tag
            if tag == "h1":
                self.h1_count += 1
        elif tag == "meta":
            self.meta[attrs.get("name", attrs.get("property", ""))] = attrs.get("content", "")
        elif tag == "link" and attrs.get("rel") == "canonical":
            self.canonical.append(attrs.get("href", ""))
        elif tag == "script" and attrs.get("type") == "application/ld+json":
            self.current = "schema"
            self.schemas.append("")
        if tag == "article":
            self.article_depth += 1

    def handle_endtag(self, tag):
        if tag in ("title", "h1", "script"):
            self.current = None
        if tag == "article":
            self.article_depth -= 1

    def handle_data(self, data):
        if self.current == "title":
            self.title.append(data)
        elif self.current == "h1":
            self.heading.append(data)
        elif self.current == "schema":
            self.schemas[-1] += data
        if self.article_depth:
            self.body.append(data)


def walk(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)


def read_time(content):
    article = re.search(r'<article\b[^>]*>(.*?)</article>', content, re.S)
    main = article[1] if article else ""
    main = re.split(r'<(?:div|aside)\b[^>]*class="[^\"]*(?:article-cta|related-guides)[^\"]*"', main, maxsplit=1)[0]
    lead = re.search(r'<p\b[^>]*class="article-lead[^\"]*"[^>]*>(.*?)</p>', content, re.S)
    plain = unescape(re.sub(r'<[^>]+>', ' ', (lead[1] if lead else "") + ' ' + main))
    return f"{max(1, math.ceil(len(plain.split()) / 200))} min read"


def load_articles():
    articles = {}
    for path in sorted((ROOT / "blog").glob("*.html")):
        if path.name == "index.html":
            continue
        parser = ArticleParser()
        content = path.read_text()
        parser.feed(content)
        expected = f"{DOMAIN}/blog/{path.name}"
        if parser.h1_count != 1 or parser.canonical != [expected]:
            raise ValueError(f"Invalid H1 or canonical: {path.name}")
        schemas = [json.loads(raw) for raw in parser.schemas]
        article = next((node for schema in schemas for node in walk(schema)
                        if node.get("@type") in ("TechArticle", "BlogPosting", "Article")), {})
        title = " ".join(parser.heading).strip()
        description = parser.meta.get("description", "").strip()
        if not title or not description or not article.get("datePublished"):
            raise ValueError(f"Missing article metadata: {path.name}")
        articles[path.name] = {
            "title": title, "description": description, "url": expected,
            "published": article["datePublished"],
            "modified": article.get("dateModified", article["datePublished"]),
            "read_time": read_time(content),
        }
    return articles


CARD = re.compile(r'<a\b[^>]*class=["\'][^"\']*\b(?:blog-card|related-guide-card)\b[^"\']*["\'][^>]*>.*?</a>', re.S)


def sync_cards(content, articles):
    def replace(match):
        card = match.group()
        href = re.search(r'\bhref=["\']([^"\']+)["\']', card)
        if not href:
            return card
        name = href.group(1).split("?", 1)[0].rsplit("/", 1)[-1]
        if not name.endswith(".html"):
            name += ".html"
        article = articles.get(name)
        if not article:
            return card
        card = re.sub(r'(<h[24]\b[^>]*class="(?:blog-card-title|related-guide-title)"[^>]*>).*?(</h[24]>)',
                      lambda m: m[1] + escape(article["title"]) + m[2], card, flags=re.S)
        card = re.sub(r'(<p\b[^>]*class="(?:blog-card-excerpt|related-guide-excerpt)"[^>]*>).*?(</p>)',
                      lambda m: m[1] + escape(article["description"]) + m[2], card, flags=re.S)
        card = re.sub(r'(<span class="blog-read-time">.*?</i>)\s*[^<]*(</span>)',
                      lambda m: m[1] + " " + article["read_time"] + m[2], card, flags=re.S)
        card = re.sub(r'(<div class="blog-card-author">\s*<i\b.*?</i>\s*<span>).*?(</span>)',
                      lambda m: m[1] + "NotchDock" + m[2], card, flags=re.S)
        return card
    return CARD.sub(replace, content)


def sync_index_schema(content, articles):
    def replace(match):
        value = json.loads(match.group(2))
        for node in walk(value):
            if node.get("@type") == "Blog":
                node["blogPost"] = [{"@type": "BlogPosting", "headline": a["title"],
                    "url": a["url"], "datePublished": a["published"],
                    "dateModified": a["modified"], "description": a["description"]}
                    for a in articles.values()]
        return match.group(1) + "\n" + json.dumps(value, ensure_ascii=False, indent=2) + "\n" + match.group(3)
    return re.sub(r'(<script\b[^>]*type="application/ld\+json"[^>]*>)(.*?)(</script>)', replace, content, flags=re.S)


def llms_text(articles, full=False):
    title = "# NotchDock documentation" if full else "# NotchDock"
    lines = [title, "", "> Official product and guide index for https://notchdock.app.", "",
        "## Product facts", "",
        "NotchDock provides sports scores, a focus timer and quick actions around the MacBook notch. The current public beta is free and requires macOS 14 or newer.",
        "", "Sports coverage is limited to the leagues available in the app. External sports and market feeds require network access and may be delayed or unavailable. A screenshot or recorded demo is not a current score or price.",
        "", "NotchDock is not an F1 timing tower or an Ollama/LM Studio telemetry monitor. No comparative battery, CPU or memory benchmark is established by this documentation.",
        "", "App permissions and macOS synchronization depend on the features enabled. Website session and download-CTA reporting is separate from app data; see the privacy policy for scope and opt-out details.",
        "", "## Start here", "",
        "- [Official website](https://notchdock.app/)",
        "- [Supported sports workflow](https://notchdock.app/features/mac-sports-tracker.html)",
        "- [Focus workflow](https://notchdock.app/features/mac-pomodoro-notes.html)",
        "- [Download and release notes](https://github.com/rohanrony/notchdock/releases)",
        "- [Privacy policy](https://notchdock.app/privacy.html)",
        "- [Support and issue reports](https://github.com/rohanrony/notchdock/issues)", ""]
    if full:
        lines.extend(["## Features and support limits", "",
            "### Sports", "",
            "The current league list includes NBA, NFL, MLB, NHL, EPL, MLS, LaLiga, Bundesliga, FIFA World Cup 2026 and UEFA Champions League. Enable a league in Sports Settings, browse its available fixtures, star a team, or pin a non-final match. Availability depends on the external feed and schedule. Formula 1, cricket, tennis and esports feeds are not in the reviewed supported list.", "",
            "### Timer and Pomodoro", "",
            "The Timer widget includes a standard countdown and Pomodoro mode. Pomodoro presets include Sprint (15/3), Classic (25/5), Deep Work (50/10) and Flow (90/20). Focus duration, break duration and cycle count can be changed in Timer Settings. Pause, Reset and Skip control the session. Auto-Start Breaks changes the transition after a focus period; see the detailed guide for phase completion behavior.", "",
            "### Stocks and quick actions", "",
            "The Stocks widget provides ticker watchlists and chart timeframes. Quote changes are different from holdings, cost basis or portfolio profit-and-loss accounting. Feed data can be delayed or unavailable. Other widgets provide notes, tasks, calendar/meeting access, clipboard shortcuts and media controls; use current product guides and release notes to check a particular integration.", "",
            "## System requirements and installation", "",
            "The current public beta requires macOS 14 or newer. Download the DMG from the official release page, open it, and move the app to Applications. Start with one workflow and grant the permissions requested for that workflow. Compatibility, permissions and release-specific changes are described in the release notes and support guides.", "",
            "## Privacy and website reporting", "",
            "App workflows and website measurement have separate data paths. Sports and stock features contact external data providers. Calendar, Reminders and Notes integrations follow the relevant macOS permissions and account/synchronization settings. Avoid interpreting local app UI as proof that no network request occurs.", "",
            "The website collector records short-lived session and download-CTA events with source labels and a coarse device category. It respects Do Not Track and Global Privacy Control. Stored records are subject to 30-day retention; a download CTA event is not proof of a completed download, install or app use. The privacy policy describes the current collection scope.", "",
            "## Support and release verification", "",
            "Use the official GitHub release destination and issue tracker above. No artifact verification result, malware-free guarantee or comparative performance measurement is established by this document. The release-verification and measurement guides explain how to inspect a specific download or collect reproducible observations.", ""])
    lines.extend(["## Guides", ""])
    for article in articles.values():
        lines.append(f'- [{article["title"]}]({article["url"]}): {article["description"]}')
    return "\n".join(lines) + "\n"


def proposed_changes():
    articles = load_articles()
    changes = {}
    for path in sorted((ROOT / "blog").glob("*.html")):
        original = path.read_text()
        updated = sync_cards(original, articles)
        if path.name == "index.html":
            updated = sync_index_schema(updated, articles)
        if updated != original:
            changes[path] = updated
    sitemap = ROOT / "public/sitemap.xml"
    original = sitemap.read_text()
    by_url = {article["url"]: article["modified"][:10] for article in articles.values()}
    if ROOT / "blog/index.html" in changes:
        by_url[DOMAIN + "/blog/"] = datetime.now(timezone.utc).date().isoformat()
    # These source pages were published separately. Derive dates from their
    # actual tracked revisions instead of assigning a fixed synchronization date.
    for relative in ["index.html", "features/mac-sports-tracker.html",
                     "features/mac-pomodoro-notes.html", "features/mac-stock-portfolio.html",
                     "features/mac-clipboard-manager.html", "features/mac-media-controller.html",
                     "features/silent-notch-notifications.html", "why-notchdock.html",
                     "compare/mac-notch-apps.html"]:
        dirty = subprocess.run(["git", "diff", "--quiet", "HEAD", "--", relative], cwd=ROOT)
        if dirty.returncode not in (0, 1):
            raise RuntimeError(f"Cannot inspect source revision: {relative}")
        if dirty.returncode == 1:
            revision_date = datetime.fromtimestamp((ROOT / relative).stat().st_mtime, timezone.utc).date().isoformat()
        else:
            result = subprocess.run(["git", "log", "-1", "--format=%cI", "--", relative],
                                    cwd=ROOT, text=True, capture_output=True, check=True)
            revision_date = result.stdout.strip()[:10]
        if re.fullmatch(r"\d{4}-\d{2}-\d{2}", revision_date):
            by_url[DOMAIN + ("/" if relative == "index.html" else "/" + relative)] = revision_date
    def replace_url(match):
        block = match.group()
        loc = re.search(r"<loc>(.*?)</loc>", block)
        date = by_url.get(unescape(loc[1])) if loc else None
        return re.sub(r"<lastmod>.*?</lastmod>", f"<lastmod>{date}</lastmod>", block) if date else block
    updated = re.sub(r"<url>.*?</url>", replace_url, original, flags=re.S)
    if updated != original:
        changes[sitemap] = updated
    for filename, full in [("llms.txt", False), ("llms-full.txt", True)]:
        path = ROOT / "public" / filename
        updated = llms_text(articles, full)
        if path.read_text() != updated:
            changes[path] = updated
    return changes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Apply metadata changes; article bodies are never generated or removed")
    args = parser.parse_args()
    changes = proposed_changes()
    for path, content in changes.items():
        if args.write:
            path.write_text(content)
        print(f'{"Updated" if args.write else "Would update"}: {path.relative_to(ROOT)}')
    print(f"{len(changes)} metadata files {'updated' if args.write else 'need synchronization'}.")
    if changes and not args.write:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
