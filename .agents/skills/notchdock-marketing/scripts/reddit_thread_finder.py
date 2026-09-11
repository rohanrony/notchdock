#!/usr/bin/env python3
"""
Reddit Thread Finder for NotchDock Marketing

Queries Reddit's public JSON API across relevant subreddits to discover
active, high-intent discussion threads, recommendation requests, and showcase threads.

Usage:
  python3 reddit_thread_finder.py [--subreddits macapps,MacOS] [--query "notch OR productivity"] [--limit 10]
"""

import sys
import json
import urllib.request
import urllib.parse
import argparse
import time

TARGET_SUBREDDITS = [
    "macapps",
    "MacOS",
    "mac",
    "macsetups",
    "productivity",
    "apple",
    "PremierLeague",
    "stocks"
]

DEFAULT_QUERIES = [
    "macbook notch app",
    "dynamic island mac",
    "best mac apps",
    "calendar meeting joiner",
    "mac menu bar widgets",
    "desktop setup mac apps",
    "live score mac",
    "apple notes quick note widget"
]

def search_via_duckduckgo(subreddit, query, limit=5):
    """Fallback search using DuckDuckGo HTML to avoid Reddit Cloudflare 403 blocks."""
    ddg_url = f"https://html.duckduckgo.com/html/?q=site:reddit.com/r/{subreddit}+{urllib.parse.quote(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
    }
    
    import ssl
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    try:
        req = urllib.request.Request(ddg_url, headers=headers)
        with urllib.request.urlopen(req, timeout=8, context=ctx) as resp:
            html = resp.read().decode("utf-8")
            
            # Extract links and titles from DDG HTML results
            import re
            links = re.findall(r'<a class="result__url" href="([^"]+)".*?<a class="result__snippet"[^>]*>(.*?)</a>', html, re.DOTALL)
            raw_titles = re.findall(r'<h2 class="result__title">.*?<a class="result__a" href="([^"]+)">(.*?)</a>', html, re.DOTALL)
            
            posts = []
            for href, raw_title in raw_titles[:limit]:
                # Clean up title and extract Reddit URL
                title = re.sub(r'<[^>]+>', '', raw_title).strip()
                # DDG redirect URL unpacking
                if "uddg=" in href:
                    match = re.search(r'uddg=([^&]+)', href)
                    if match:
                        href = urllib.parse.unquote(match.group(1))
                
                if f"reddit.com/r/{subreddit}" in href:
                    posts.append({
                        "id": "web_result",
                        "subreddit": subreddit,
                        "title": title,
                        "author": "community",
                        "score": "N/A",
                        "num_comments": "N/A",
                        "created_utc": time.time(),
                        "permalink": href,
                        "url": href,
                        "is_self": True,
                        "selftext_preview": f"Discovered via web search for r/{subreddit}"
                    })
            return posts
    except Exception as e:
        return []

def search_subreddit(subreddit, query, limit=5, sort="new", time_filter="week"):
    endpoints = [
        f"https://www.reddit.com/r/{subreddit}/search.json?q={urllib.parse.quote(query)}&restrict_sr=1&sort={sort}&t={time_filter}&limit={limit}",
        f"https://safereddit.com/r/{subreddit}/search.json?q={urllib.parse.quote(query)}&restrict_sr=1&sort={sort}&t={time_filter}&limit={limit}"
    ]
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
        "Accept": "application/json, text/plain, */*"
    }
    
    import ssl
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    last_error = None
    for url in endpoints:
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=5, context=ctx) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                posts = []
                for child in data.get("data", {}).get("children", []):
                    p = child.get("data", {})
                    posts.append({
                        "id": p.get("id"),
                        "subreddit": p.get("subreddit"),
                        "title": p.get("title"),
                        "author": p.get("author"),
                        "score": p.get("score"),
                        "num_comments": p.get("num_comments"),
                        "created_utc": p.get("created_utc"),
                        "permalink": f"https://www.reddit.com{p.get('permalink')}",
                        "url": p.get("url"),
                        "is_self": p.get("is_self"),
                        "selftext_preview": (p.get("selftext") or "")[:200].replace("\n", " ")
                    })
                if posts:
                    return posts
        except Exception as e:
            last_error = str(e)
            continue

    # Fallback to DuckDuckGo Reddit search
    web_posts = search_via_duckduckgo(subreddit, query, limit=limit)
    if web_posts:
        return web_posts
            
    return [{"error": f"Search fallback active for r/{subreddit}. Query: site:reddit.com/r/{subreddit} {query}"}]

def main():
    parser = argparse.ArgumentParser(description="Find active Reddit threads for NotchDock marketing")
    parser.add_argument("--subreddits", type=str, default=",".join(TARGET_SUBREDDITS[:4]), help="Comma-separated subreddits")
    parser.add_argument("--query", type=str, default="", help="Custom search query")
    parser.add_argument("--limit", type=int, default=5, help="Results per subreddit")
    parser.add_argument("--sort", type=str, default="new", choices=["new", "relevance", "hot", "top"], help="Sort order")
    parser.add_argument("--time", type=str, default="month", choices=["day", "week", "month", "year", "all"], help="Time window")
    args = parser.parse_args()

    subs = [s.strip() for s in args.subreddits.split(",") if s.strip()]
    query = args.query if args.query else " OR ".join(['"notch"', '"mac apps"', '"productivity"'])

    print(f"[*] Searching Reddit across: {', '.join(subs)}")
    print(f"[*] Query: {query}")
    print(f"[*] Window: {args.time} | Sort: {args.sort}\n")

    all_results = {}
    for sub in subs:
        print(f"--- r/{sub} ---")
        results = search_subreddit(sub, query, limit=args.limit, sort=args.sort, time_filter=args.time)
        all_results[sub] = results
        for idx, r in enumerate(results, 1):
            if "error" in r:
                print(f"  [!] {r['error']}")
                continue
            print(f"  {idx}. [{r['score']} pts | {r['num_comments']} cmts] {r['title']}")
            print(f"     URL: {r['permalink']}")
            if r['selftext_preview']:
                print(f"     Snippet: {r['selftext_preview']}...")
        print()
        time.sleep(1) # Polite pause

if __name__ == "__main__":
    main()
