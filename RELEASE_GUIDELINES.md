# NotchDock Public Release Guidelines

This guide details the steps to synchronize, update, and push the latest NotchDock application releases from the core development repository to the public website repository.

---

## 🛠️ Step 1: Copy Latest Release Assets
Because macOS IDEs and code assistants run in a restricted App Sandbox, copying binary files must be executed from a **native macOS Terminal** (Terminal.app or iTerm2).

Open your native Terminal, navigate to the public directory, and run the copy commands:

```bash
# Navigate to the public repository
cd /Users/rohanroy/Coding/notchdock-public

# Copy the latest README.md
cp /Users/rohanroy/Coding/notchdock/README.md ./

# Copy the latest compiled NotchDock.dmg installer
cp /Users/rohanroy/Coding/notchdock/NotchDock.dmg ./
```

---

## 🏷️ Step 2: Determine & Update the Version
1. Open the core development changelog at `/Users/rohanroy/Coding/notchdock/CHANGELOG.md` to identify the latest version tag (e.g., `## [0.13.6]`).
2. Update the version string in the following public repository files:

### A. Update `package.json`
Locate the `"version"` field in the root of `package.json` and set it to match:
```json
{
  "name": "notchdock-public",
  "version": "0.13.6",
  ...
}
```

### B. Update `index.html`
Locate the version badge span around line 108 in `index.html` and update it:
```html
<span>v0.13.6 Beta</span>
```

---

## 🚀 Step 3: Verify and Deploy to Dev
Once files and version numbers are updated, commit and push the changes to the `dev` branch on GitHub:

```bash
# Add all changed files (including README.md, NotchDock.dmg, package.json, index.html)
git add README.md NotchDock.dmg package.json index.html

# Commit the updates
git commit -m "chore: update release assets and version to v0.13.6"

# Ensure you are on the dev branch and push
git checkout dev 2>/dev/null || git checkout -b dev
git push origin dev
```
