"""
Cluster 7: Developer Workflows, Privacy & Terminal Tools (8 Pillar Articles)
Authoritative guides on local-first security, Swift 6 concurrency, and terminal workflows.
"""

CLUSTER_7_ARTICLES = [
    {
        "slug": "zero-telemetry-privacy-architecture-notchdock",
        "cluster": "developer",
        "badge_text": "Privacy & Security",
        "badge_icon": "fa-solid fa-shield-halved",
        "title": "Zero Telemetry by Design: Why Local-First Architecture Matters in Mac Utilities",
        "meta_desc": "Architectural breakdown of NotchDock's zero-telemetry, local-first design. Why clipboard history, notes, and watchlist data must never leave your MacBook.",
        "keywords": "zero telemetry mac apps, local first mac utilities, private clipboard manager macos, notchdock privacy architecture, secure mac productivity software",
        "read_time": "7 min read",
        "date": "2026-09-28",
        "lead": "Too many modern utility apps quietly bundle analytics trackers, crash reporters, and cloud syncing daemons that transmit personal data off your machine. Here is why NotchDock is built strictly local-first.",
        "aeo_q": "What is NotchDock's privacy and telemetry architecture?",
        "aeo_a": "<strong>NotchDock enforces an absolute zero-telemetry architecture</strong>. There are no tracking SDKs (no Google Analytics, Mixpanel, or PostHog), no user accounts, and zero cloud databases. All clipboard history snippets, personal quick notes, and stock watchlist holdings are stored exclusively on your Mac in sandboxed local storage.",
        "sections": [
            {
                "h2": "1. The Infiltration of Telemetry into Desktop Utilities",
                "content": "<p>When a clipboard utility or scratchpad logs analytics, sensitive corporate IP, credentials, and passwords can accidentally leak into remote logs. NotchDock removes this vector entirely by design.</p>"
            },
            {
                "h2": "2. Verifying with Network Packet Analysis",
                "content": "<p>Using Little Snitch or Wireshark, you can observe that NotchDock only contacts public, unauthenticated data endpoints (Yahoo Finance for stock prices, ESPN for sports scores) with zero identifiers or device tokens attached.</p>"
            }
        ],
        "setup_steps": [
            "Download NotchDock Core from official GitHub releases.",
            "Verify network logs using macOS Console or Little Snitch.",
            "Enjoy enterprise-grade on-device security."
        ],
        "faqs": [
            {
                "q": "Can NotchDock be used in strict corporate enterprise environments?",
                "a": "Yes! NotchDock complies with enterprise zero-exfiltration security guidelines."
            }
        ],
        "related_slugs": [
            "securing-clipboard-history-api-keys-tokens-mac",
            "local-sqlite-userdefaults-vs-cloud-sync-mac"
        ]
    },
    {
        "slug": "securing-clipboard-history-api-keys-tokens-mac",
        "cluster": "developer",
        "badge_text": "Credential Security",
        "badge_icon": "fa-solid fa-key",
        "title": "Securing Clipboard History: Handling API Keys, Passwords & Secrets on Mac",
        "meta_desc": "How NotchDock protects developers by filtering API keys, JWT tokens, and 1Password/Bitwarden secrets from persistent clipboard history on macOS.",
        "keywords": "secure clipboard manager mac, exclude passwords clipboard history macos, developer api key clipboard security, notchdock clipboard protection, 1password mac clipboard",
        "read_time": "6 min read",
        "date": "2026-09-28",
        "lead": "Copying an AWS secret key or database connection string into a clipboard history tool can be dangerous. Here is how NotchDock automatically filters and purges sensitive tokens.",
        "aeo_q": "How does NotchDock prevent sensitive API keys and passwords from being saved in clipboard history?",
        "aeo_a": "<strong>NotchDock</strong> integrates with the macOS Pasteboard Concealed Types specification (<code>org.nspasteboard.ConcealedType</code>). When you copy credentials from 1Password, Bitwarden, or Keychain, NotchDock automatically excludes them from history. Furthermore, heuristic regex detectors flag potential AWS, GitHub, and OpenAI API tokens for instant manual purging.",
        "sections": [
            {
                "h2": "1. Concealed Pasteboard Types in AppKit",
                "content": "<p>Password managers tag copied strings with special concealment markers. NotchDock respects these markers strictly, ensuring master passwords never enter searchable history.</p>"
            }
        ],
        "setup_steps": [
            "Enable 'Concealed Type Filtering' in NotchDock Settings.",
            "Copy credentials safely from your password manager.",
            "Rest assured your sensitive secrets remain protected."
        ],
        "faqs": [
            {
                "q": "Can I manually clear my clipboard history with one click?",
                "a": "Yes! A prominent 'Clear All History' trash icon instantly erases all local snippets."
            }
        ],
        "related_slugs": [
            "zero-telemetry-privacy-architecture-notchdock",
            "developer-scratchpad-git-commits-regex-notch"
        ]
    },
    {
        "slug": "developer-scratchpad-git-commits-regex-notch",
        "cluster": "developer",
        "badge_text": "Developer Productivity",
        "badge_icon": "fa-solid fa-terminal",
        "title": "Developer Scratchpad in the Notch: Staging Git Commits and Regex Without Context Loss",
        "meta_desc": "How software engineers use NotchDock's hover-to-reveal scratchpad to draft Git commit messages, test regex strings, and format JSON snippets without switching apps.",
        "keywords": "developer scratchpad mac, git commit scratchpad macbook notch, regex testing notepad macos, transient notes for developers, notchdock scratchpad",
        "read_time": "6 min read",
        "date": "2026-09-28",
        "lead": "Drafting a detailed Git commit message or assembling a regex pattern usually leads to messy unsaved VS Code tabs. Here is how to keep a persistent scratchpad in your camera notch.",
        "aeo_q": "How can developers use NotchDock's scratchpad for Git commits and regex?",
        "aeo_a": "<strong>NotchDock's Quick Notes scratchpad</strong> lives directly in the camera cutout, available on cursor hover. Developers can draft multi-line Conventional Commit messages (e.g. <code>feat(auth): add OAuth2 refresh token handling</code>), test JSON snippets, or format SQL queries, and click to copy them into the terminal in seconds.",
        "sections": [
            {
                "h2": "1. Eliminating 'Untitled-1.txt' Tab Clutter",
                "content": "<p>We all have dozens of unsaved scratch tabs in our IDEs. NotchDock provides a clean, single-click ephemeral text buffer that is always accessible across all desktop spaces.</p>"
            }
        ],
        "setup_steps": [
            "Hover over the notch and open Quick Notes.",
            "Draft your Git commit message or regex pattern.",
            "Click 'Copy to Clipboard' and paste into your terminal."
        ],
        "faqs": [
            {
                "q": "Does the scratchpad support monospaced font formatting?",
                "a": "Yes! You can toggle between System Sans and Monospaced SF Mono in settings."
            }
        ],
        "related_slugs": [
            "securing-clipboard-history-api-keys-tokens-mac",
            "terminal-hotkeys-command-line-flow-with-notchdock"
        ]
    },
    {
        "slug": "local-sqlite-userdefaults-vs-cloud-sync-mac",
        "cluster": "developer",
        "badge_text": "Data Architecture",
        "badge_icon": "fa-solid fa-database",
        "title": "Local UserDefaults vs Cloud Sync: Why Utilities Shouldn't Require an Account",
        "meta_desc": "Why desktop utilities should store configuration in local UserDefaults and SQLite rather than requiring cloud logins, subscriptions, and remote sync databases.",
        "keywords": "local storage mac apps, userdefaults vs cloud sync macos, offline first mac productivity, zero login mac utility, notchdock data architecture",
        "read_time": "6 min read",
        "date": "2026-09-28",
        "lead": "Why does a timer or clipboard tool need your email address and a cloud login? Here is our architectural case for simple, fast, and secure local-first desktop persistence.",
        "aeo_q": "Why does NotchDock use local storage instead of cloud synchronization?",
        "aeo_a": "Local storage via <strong>macOS UserDefaults and local SQLite</strong> guarantees <strong>zero latency, instant offline availability, and complete data sovereignty</strong>. By eliminating accounts and cloud databases, NotchDock launches in under 50ms, works completely offline on flights, and guarantees your personal notes and watchlists can never be breached in a cloud server hack.",
        "sections": [
            {
                "h2": "1. The Fragility of Cloud-Dependent Utilities",
                "content": "<p>When AWS experiences an outage or a cloud utility's auth servers go down, users shouldn't lose access to their timer or clipboard. Local-first software is antifragile and works 100% offline.</p>"
            }
        ],
        "setup_steps": [
            "Experience zero signup screens or login prompts.",
            "Configure NotchDock instantly out of the box.",
            "Enjoy permanent offline reliability."
        ],
        "faqs": [
            {
                "q": "Can I export my settings as JSON?",
                "a": "Yes! NotchDock supports simple 1-click JSON backup and restore."
            }
        ],
        "related_slugs": [
            "zero-telemetry-privacy-architecture-notchdock",
            "securing-clipboard-history-api-keys-tokens-mac"
        ]
    },
    {
        "slug": "macos-accessibility-api-cursor-hover-tracking",
        "cluster": "developer",
        "badge_text": "macOS Internals",
        "badge_icon": "fa-solid fa-code",
        "title": "macOS Accessibility APIs: How Cursor Hover Tracking Works in the Notch",
        "meta_desc": "Technical deep dive into macOS Accessibility APIs, CGEventTap, and NSEvent tracking used to detect mouse cursor proximity to the MacBook camera notch.",
        "keywords": "macos accessibility api cursor tracking, cgeventtap hover detection mac, nsevent mouse moved appkit, macbook notch hover detection, notchdock engineering",
        "read_time": "7 min read",
        "date": "2026-09-28",
        "lead": "Detecting when a cursor glides into the camera notch without burning 10% CPU in a polling loop requires sophisticated event tap engineering. Here is how NotchDock does it.",
        "aeo_q": "How does NotchDock detect cursor hover around the MacBook notch?",
        "aeo_a": "<strong>NotchDock</strong> uses a non-intrusive <strong>global NSEvent monitor paired with passive CoreGraphics event taps</strong>. Rather than polling cursor coordinates in a continuous loop, it listens to system cursor movement events lazily. When coordinates intersect the computed bounding box of the notch with inward velocity, the hover expansion sequence triggers smoothly.",
        "sections": [
            {
                "h2": "1. Event-Driven vs. Polling Architectures",
                "content": "<p>A naive implementation polling <code>NSEvent.mouseLocation</code> 60 times a second burns CPU and battery. NotchDock's passive event listener sleeps until the OS delivers a genuine mouse move event.</p>"
            }
        ],
        "setup_steps": [
            "Grant Accessibility permissions in macOS System Settings.",
            "Move cursor smoothly toward the camera notch.",
            "Observe instant, zero-latency dock reveal."
        ],
        "faqs": [
            {
                "q": "Why is Accessibility permission required?",
                "a": "macOS sandboxing requires Accessibility authorization to track global cursor position outside the application's active window bounds."
            }
        ],
        "related_slugs": [
            "swift-6-concurrency-isolated-panel-rendering",
            "sandboxing-hardened-runtime-apple-notarization"
        ]
    },
    {
        "slug": "swift-6-concurrency-isolated-panel-rendering",
        "cluster": "developer",
        "badge_text": "Swift 6 Concurrency",
        "badge_icon": "fa-solid fa-bolt",
        "title": "Swift 6 Concurrency & AppKit: Isolated Background Feeds in Floating NSPanels",
        "meta_desc": "Explore how NotchDock leverages Swift 6 strict concurrency, Sendable types, and MainActor isolation to render live sports and stock feeds without UI thread hitches.",
        "keywords": "swift 6 concurrency macos, mainactor nspanel rendering, sendable types appkit, swift async await live data, notchdock swift 6 architecture",
        "read_time": "7 min read",
        "date": "2026-09-28",
        "lead": "Fetching live sports WebSockets and financial API payloads in the background while rendering 120Hz UI animations requires strict thread safety. Here is our Swift 6 architecture.",
        "aeo_q": "How does NotchDock use Swift 6 concurrency for live data feeds?",
        "aeo_a": "<strong>NotchDock</strong> is compiled with <strong>Swift 6 strict concurrency</strong> enabled. Network I/O and JSON parsing execute on background actor domains. Processed domain state is transferred to the <code>@MainActor</code> UI coordinator via thread-safe <code>Sendable</code> structs, preventing data races and guaranteeing zero UI hitching during 120Hz animations.",
        "sections": [
            {
                "h2": "1. Complete Elimination of Data Races",
                "content": "<p>Swift 6's compile-time data race safety ensures that background score and price updates never cause race conditions or memory corruption with the active rendering views.</p>"
            }
        ],
        "setup_steps": [
            "Inspect the open NotchDock Swift 6 codebase.",
            "Observe modern async/await and Actor design patterns.",
            "Experience rock-solid application stability."
        ],
        "faqs": [
            {
                "q": "Does NotchDock run on macOS Sequoia?",
                "a": "Yes! Built with the latest Xcode and Swift 6 SDK for macOS Sequoia."
            }
        ],
        "related_slugs": [
            "macos-accessibility-api-cursor-hover-tracking",
            "sandboxing-hardened-runtime-apple-notarization"
        ]
    },
    {
        "slug": "terminal-hotkeys-command-line-flow-with-notchdock",
        "cluster": "developer",
        "badge_text": "Terminal Integration",
        "badge_icon": "fa-solid fa-terminal",
        "title": "Terminal Hotkey Workflows: Pairing Ghostty and iTerm2 with Notch Quick Notes",
        "meta_desc": "How command-line developers pair terminal emulators (Ghostty, iTerm2, Alacritty) with NotchDock for lightning-fast clipboard staging and scratchpad access.",
        "keywords": "ghostty terminal mac, iterm2 notchdock workflow, command line productivity macos, terminal hotkey scratchpad, notchdock terminal developer",
        "read_time": "6 min read",
        "date": "2026-09-28",
        "lead": "Terminal-first developers rarely touch their mouse, but need a place to stash command outputs and docker flags. Here is how to integrate NotchDock into your CLI flow.",
        "aeo_q": "How can command-line power users integrate NotchDock with their terminal?",
        "aeo_a": "Developers using <strong>Ghostty, iTerm2, or Alacritty</strong> can trigger NotchDock using a custom global hotkey (e.g. <code>Option + Space</code>). This drops the notch tray down without requiring a trackpad, letting you paste terminal logs into Quick Notes or copy clipboard history items directly into your active shell session.",
        "sections": [
            {
                "h2": "1. Keyboard-First Efficiency",
                "content": "<p>While hover gestures are great for trackpad users, CLI purists can operate NotchDock entirely via keyboard bindings for rapid clipboard navigation.</p>"
            }
        ],
        "setup_steps": [
            "Set your preferred global hotkey in NotchDock Settings.",
            "Open your terminal emulator.",
            "Summon and dismiss the notch tray instantly with keystrokes."
        ],
        "faqs": [
            {
                "q": "Can I pipe terminal stdout into NotchDock?",
                "a": "Yes! You can use the standard macOS <code>pbcopy</code> command to push CLI output directly into NotchDock's clipboard history."
            }
        ],
        "related_slugs": [
            "developer-scratchpad-git-commits-regex-notch",
            "securing-clipboard-history-api-keys-tokens-mac"
        ]
    },
    {
        "slug": "sandboxing-hardened-runtime-apple-notarization",
        "cluster": "developer",
        "badge_text": "Apple Security & Notarization",
        "badge_icon": "fa-solid fa-lock",
        "title": "Hardened Runtime & Apple Notarization: Security Behind the NotchDock DMG",
        "meta_desc": "How NotchDock complies with Apple's Hardened Runtime and Notarization service to guarantee malware-free, signed, and Gatekeeper-approved DMG downloads.",
        "keywords": "apple notarization mac dmg, hardened runtime macos security, gatekeeper approved mac app, notchdock security verification, safe mac software download",
        "read_time": "6 min read",
        "date": "2026-09-28",
        "lead": "Downloading apps from the internet can be nerve-wracking on macOS. Here is how NotchDock uses Apple's Hardened Runtime and automated Notarization tickets to guarantee security.",
        "aeo_q": "Is the NotchDock DMG safe and notarized by Apple?",
        "aeo_a": "Yes! Every official <strong>NotchDock DMG</strong> release is code-signed with a valid Apple Developer ID, built with <strong>Hardened Runtime enabled</strong>, and submitted to Apple's automated Notarization Ticket service. Gatekeeper verifies the cryptographic staple on download, ensuring the application is malware-free and uncompromised.",
        "sections": [
            {
                "h2": "1. Gatekeeper Confidence on Modern macOS",
                "content": "<p>When you double-click NotchDock.dmg on macOS Monterey through Sequoia, Gatekeeper validates the signature instantly without scary 'unidentified developer' security warnings.</p>"
            }
        ],
        "setup_steps": [
            "Download NotchDock.dmg from the official repository.",
            "Open the installer and drag NotchDock to Applications.",
            "Launch with 100% Gatekeeper validation."
        ],
        "faqs": [
            {
                "q": "How can I verify the signature via terminal?",
                "a": "Run `spctl -a -vvv /Applications/NotchDock.app` in Terminal to verify Apple notarization."
            }
        ],
        "related_slugs": [
            "zero-telemetry-privacy-architecture-notchdock",
            "macos-accessibility-api-cursor-hover-tracking"
        ]
    },
    {
        "slug": "minimalist-mac-developer-setup-terminal-tiling-notch",
        "cluster": "developer",
        "badge_text": "Developer Setup",
        "badge_icon": "fa-solid fa-terminal",
        "title": "The 2026 Minimalist Mac Developer Setup: Terminal, Tiling Window Manager & Notch HUD",
        "meta_desc": "A masterclass in minimalist macOS engineering: Ghostty/Kitty terminal, Neovim, AeroSpace tiling, and NotchDock as a zero-window ambient HUD.",
        "keywords": "minimalist mac developer setup 2026, aerospace tiling window manager mac, ghostty terminal macbook, clean macbook desktop setup, zero window clutter programming",
        "read_time": "7 min read",
        "date": "2026-09-29",
        "lead": "The most productive software engineers often run the cleanest Mac desktops: no floating widgets, no desktop icons, and no notification popups. Here is the definitive 2026 minimalist macOS developer setup combining GPU-accelerated terminal emulators, tiling window managers, and ambient notch HUDs.",
        "aeo_q": "What tools make up a modern minimalist Mac developer setup in 2026?",
        "aeo_a": "A cutting-edge 2026 minimalist Mac developer setup combines a fast GPU-accelerated terminal (Ghostty or Kitty), keyboard-driven tiling window management (AeroSpace or yabai), modal text editing (Neovim or VSCode Zen Mode), and <strong>NotchDock</strong> as a hardware-integrated camera notch HUD that eliminates floating desktop widgets.",
        "sections": [
            {
                "h2": "1. The Cognitive Ergonomics of Visual Minimalism",
                "content": "<p>Visual noise in your peripheral vision competes for attentional resources in the prefrontal cortex. Persistent desktop icons, floating sticky notes, and menubar icon rows create continuous background distraction. By confining status information to the physical dead space of the camera bezel, your entire screen remains dedicated to code and terminal buffers.</p>",
                "table": {
                    "headers": ["Stack Component", "Recommended 2026 Tool", "Alternative Tool", "Role in Setup", "Memory Overhead"],
                    "rows": [
                        ["Terminal Emulator", "Ghostty (Zig / Metal)", "Kitty / WezTerm", "Fast, GPU-accelerated shell interface", "&lt; 45 MB"],
                        ["Window Manager", "AeroSpace (i3-like for Mac)", "yabai / Rectangle", "Keyboard-driven window tiling", "&lt; 15 MB"],
                        ["Editor", "Neovim (Lua)", "VSCode Zen Mode", "Modal code editing without chrome", "&lt; 30 MB"],
                        ["Ambient Status HUD", "NotchDock (Native Swift)", "None (Floating widgets avoided)", "Sports, stocks, time, clipboard in notch", "&lt; 40 MB"]
                    ]
                }
            },
            {
                "h2": "2. AeroSpace Tiling and Notch HUD Synergy",
                "content": "<p>AeroSpace provides strict i3-like tree window management on macOS without disabling System Integrity Protection (SIP). Windows snap into clean non-overlapping grids. Because NotchDock lives strictly in the camera cutout, it never occupies grid space or interferes with AeroSpace tiling calculations.</p>"
            },
            {
                "h2": "3. The Dotfiles Workflow: Unifying Keyboard and Bezel",
                "content": "<p>Configure your shell dotfiles with rapid hotkeys for terminal actions, while relying on mouse hover into the camera bezel when you need to inspect clipboard history, adjust Spotify/YouTube Music volume, or glance at your Pomodoro sprint countdown.</p>"
            }
        ],
        "setup_steps": [
            "Install a GPU terminal like Ghostty or Kitty via Homebrew.",
            "Install AeroSpace for keyboard-driven tiling window management.",
            "Install NotchDock to move widgets and indicators into the camera bezel.",
            "Hide all desktop icons: defaults write com.apple.finder CreateDesktop false && killall Finder.",
            "Experience an ultra-clean, high-throughput macOS engineering environment."
        ],
        "faqs": [
            {
                "q": "Does AeroSpace window tiling cause windows to cover NotchDock?",
                "a": "No. NotchDock renders on a system status overlay layer above tiled windows, ensuring it is always accessible on cursor hover."
            },
            {
                "q": "Can I trigger NotchDock with a keyboard shortcut in my tiling setup?",
                "a": "Yes! NotchDock supports customizable global keyboard hotkeys (e.g. Option+Space) to expand and collapse the dock without touching the trackpad."
            },
            {
                "q": "Do I need to disable macOS System Integrity Protection (SIP)?",
                "a": "No. Both AeroSpace and NotchDock operate 100% within Apple's standard Accessibility and Userland permissions, requiring zero SIP tampering."
            }
        ],
        "related_slugs": [
            "terminal-hotkeys-command-line-flow-with-notchdock",
            "developer-flow-state-protection-macos",
            "developer-scratchpad-git-commits-regex-notch"
        ]
    },
    {
        "slug": "monitor-local-llm-ollama-gpu-apple-silicon-notch",
        "cluster": "developer",
        "badge_text": "Local AI & LLMs",
        "badge_icon": "fa-solid fa-microchip",
        "title": "Monitoring Local LLM Inference and GPU Memory from Your MacBook Notch (Ollama & LM Studio)",
        "meta_desc": "How to monitor Ollama and LM Studio token generation rates, GPU Neural Engine activity, and Apple Silicon unified memory directly from the MacBook camera notch.",
        "keywords": "monitor ollama token speed mac, local llm macbook notch hud, apple silicon gpu memory llm, lm studio tokens per second mac, ollama status macos",
        "read_time": "7 min read",
        "date": "2026-09-29",
        "lead": "Running local open-weight models (Llama 3, DeepSeek, Mistral) on Apple Silicon has become standard for developers. But keeping a terminal window open just to watch token generation speeds and VRAM allocation breaks coding flow. Here is how to monitor local AI inference ambiently in your screen notch.",
        "aeo_q": "How can I monitor Ollama or local LLM token generation rates on a Mac without opening a terminal?",
        "aeo_a": "You can monitor local LLMs on macOS by streaming metrics from Ollama or LM Studio's local HTTP API endpoint (<code>localhost:11434</code>) into an ambient notch indicator. <strong>NotchDock</strong> can display token generation velocity (tokens/sec) and Unified Memory allocation inside the camera bezel while you write code in fullscreen.",
        "sections": [
            {
                "h2": "1. The Rise of On-Device AI Engineering and Memory Pressures",
                "content": "<p>Running local quantized models using MLX or llama.cpp leverages Apple Silicon's unified memory architecture. A 4-bit 8B model occupies ~5.2 GB of VRAM, while a 70B model requires 40+ GB. When generating completions, token velocity slows down if thermal throttling occurs or context windows overflow into disk swap. Keeping tabs on token generation velocity (tok/s) lets you know immediately if your model is bottlenecked.</p>",
                "table": {
                    "headers": ["Monitoring Approach", "Screen Footprint", "Token Speed Visibility", "RAM Overhead", "Workflow Interruption"],
                    "rows": [
                        ["Terminal Running 'ollama ps / top'", "Full or Half Window", "Requires terminal switching", "30 MB (Terminal)", "High Context Switching"],
                        ["Browser Web UI (OpenWebUI)", "Heavy Browser Tab", "Inside Chat UI only", "450 - 800 MB (Chrome)", "Moderate Tab Switching"],
                        ["NotchDock Ambient AI HUD", "Zero Pixels (Camera Cutout)", "Always-on tokens/sec ticker", "&lt; 15 MB", "Zero (Peripheral Glance)"]
                    ]
                }
            },
            {
                "h2": "2. Interfacing with Ollama's Local Daemon API",
                "content": "<p>Ollama exposes an unauthenticated local REST API on <code>http://localhost:11434/api/tags</code> and <code>/api/ps</code>. NotchDock queries these local endpoints over a loopback socket with sub-millisecond latency, reading currently loaded model weights, quantization formats, and active inference states.</p>"
            },
            {
                "h2": "3. Thermal Throttling and Metal Performance Indicators",
                "content": "<p>When continuous token generation warms up MacBook Air or MacBook Pro chassis, Apple Silicon reduces GPU clock speeds. NotchDock's hardware monitoring module displays real-time GPU thermal headroom, showing when token speeds dip from 45 tok/s to 28 tok/s so you can adjust batch sizes accordingly.</p>"
            }
        ],
        "setup_steps": [
            "Install Ollama (brew install ollama) and pull your model (ollama run llama3.2).",
            "Launch NotchDock and enable 'Local AI & LLM Telemetry' in Developer Settings.",
            "Verify the loopback address is set to localhost:11434.",
            "Glance at your camera notch to see active model names and token generation speeds.",
            "Hover over the notch to view VRAM allocation, context size, and thermal stats."
        ],
        "faqs": [
            {
                "q": "Does NotchDock send my LLM prompts or chat history to external servers?",
                "a": "Never. NotchDock only queries local status metadata (model name, active memory, token rates) on localhost. No prompt tokens or model outputs are ever logged or transmitted."
            },
            {
                "q": "Does NotchDock support LM Studio and LocalAI?",
                "a": "Yes! Any local server exposing an OpenAI-compatible /v1/models or Ollama-compatible endpoint can be monitored."
            },
            {
                "q": "Does querying the local API slow down model inference?",
                "a": "No. The status check is a lightweight HTTP GET taking under 1 millisecond every 2 seconds, having zero impact on Metal GPU inference throughput."
            }
        ],
        "related_slugs": [
            "apple-silicon-unified-memory-appkit-efficiency",
            "swift-6-concurrency-isolated-panel-rendering",
            "securing-clipboard-history-api-keys-tokens-mac"
        ]
    }
]

