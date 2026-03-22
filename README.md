# AI Performance Guardrails 🛡️

**Stop your AI from pushing bloated, slow code to production.**

This is a strict verification loop that forces AI coding assistants (Claude Code, Cursor, GitHub Copilot, etc.) to run Lighthouse performance checks *before* finalizing code chunks. If performance drops below 100%, the AI automatically refines its own code until it passes.

## Why use this?

✅ **Zero Setup Friction** — Drop 3 files into your project and you're done
✅ **Self-Healing Code** — AI reads Lighthouse failures and fixes them automatically
✅ **No Manual Audits** — Keep Next.js, React, Vue apps blazing fast without you lifting a finger
✅ **Instant Adoption** — Claude Code picks up `CLAUDE.md` automatically

## ⚡ One-Minute Installation

Run these commands in your project root:

```bash
# 1. Grab the AI instructions and Lighthouse config
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/ai-performance-guardrails/main/CLAUDE.md
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/ai-performance-guardrails/main/lighthouserc.js

# 2. Grab the enforcer script
mkdir -p scripts
curl -o scripts/check-speed.js https://raw.githubusercontent.com/YOUR_USERNAME/ai-performance-guardrails/main/scripts/check-speed.js

# 3. Install the Lighthouse CI dependency (if not already installed)
npm install -D @lhci/cli
```

Then add this to your `package.json`:

```json
{
  "scripts": {
    "check-speed": "node scripts/check-speed.js"
  }
}
```

**That's it.** Claude Code will automatically load `CLAUDE.md` and enforce performance standards.

---

## How It Works

1. **You ask Claude Code to build/update code**
2. **CLAUDE.md directive kicks in** — AI runs `npm run check-speed`
3. **Lighthouse builds and tests your project** — Lighthouse CI validates performance
4. **AI reads the results**:
   - ✅ **Score ≥ 100%?** Code is committed. Done.
   - ❌ **Score < 100%?** AI identifies the bottleneck and refactors automatically
5. **Loop repeats** until performance target is met

---

## What Gets Enforced

By default, `lighthouserc.js` enforces:

- **Performance: 100%** (strict)
- **Accessibility: ≥ 80%** (warning)
- **Best Practices: ≥ 80%** (warning)
- **SEO: ≥ 80%** (warning)

You can tweak thresholds in `lighthouserc.js` to match your standards.

---

## Customization

### Change performance thresholds

Edit `lighthouserc.js`:

```javascript
'categories:performance': ['error', { minScore: 0.95 }],  // 95% instead of 100%
```

### Change the start command

If you're not using Next.js, update `scripts/check-speed.js`:

```javascript
execSync('yarn dev', { stdio: 'inherit' });  // or 'npm start', etc.
```

### Disable specific checks

In `lighthouserc.js`:

```javascript
'cumululative-layout-shift': ['off'],  // Turn off CLS check
```

---

## Optional: Add Google Analytics MCP Server

You can integrate the **Google Analytics Model Context Protocol (MCP)** server to give Claude Code access to your analytics data. This lets the AI make performance decisions based on real user metrics.

### Setup GA MCP

1. **Install the MCP server:**
   ```bash
   # Follow instructions at https://github.com/googleanalytics/google-analytics-mcp
   ```

2. **Add GA MCP to Claude Code settings** (in `settings.json`):
   ```json
   {
     "mcpServers": {
       "google-analytics": {
         "command": "node",
         "args": ["path/to/google-analytics-mcp/server.js"]
       }
     }
   }
   ```

3. **Ask Claude Code to check your data:**
   - "What's our Core Web Vitals score for the last 7 days?"
   - "Which pages have the slowest load times?"
   - "How did our performance metrics change after that deploy?"

The AI can now correlate Lighthouse checks with real user experience data before committing code.

---

## Example Workflow

```
You: "Add a hero section with background images"

Claude Code:
  1. Writes the component
  2. Runs: npm run check-speed
  3. ❌ Lighthouse: 68% (images are 2.3MB unoptimized)
  4. Refactors: Adds next/image, WebP conversion, lazy loading
  5. Runs: npm run check-speed
  6. ✅ Lighthouse: 100% ← Code committed
```

---

## Troubleshooting

### "Cannot find module @lhci/cli"

```bash
npm install -D @lhci/cli
```

### Lighthouse fails to connect to localhost:3000

- Make sure `npm run start` or `npm run dev` works for your project
- Update the start command in `scripts/check-speed.js` if needed

### Performance threshold too strict

Edit `lighthouserc.js` and lower the `minScore` value (0.0–1.0 scale).

---

## Contributing

Found a bug? Have a better check? Submit a PR!

We welcome contributions for:
- Playwright/E2E testing integration
- CI/CD pipeline examples (GitHub Actions, GitLab, etc.)
- Framework-specific optimizations
- Better error messaging

---

## License

MIT — Use freely in your projects.

---

*Built to keep the web fast.* ⚡
