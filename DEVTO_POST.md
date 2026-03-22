# I Built a Tool to Stop Claude Code from Shipping Slow Code

I got tired of asking Claude Code to build something, and it would work perfectly... but load in 8 seconds instead of 2.

So I built **AI Performance Guardrails** — a tool that forces Claude (and any AI assistant) to validate code against **three** critical measures before finalizing anything:

1. **Lighthouse 100%** (synthetic performance tests)
2. **Real user data** (Google Analytics Core Web Vitals)
3. **Search health** (Google Search Console rankings + crawl errors)

If ANY of them fail, the AI automatically refactors its own code until everything passes.

## The Problem

AI coding assistants are amazing, but they optimize for:
- ✅ Code that works
- ✅ Features that ship fast
- ❌ **Performance that doesn't regress**

A bloated bundle passes testing. Unoptimized images look fine in localhost. Third-party scripts don't show up in Lighthouse until production.

Then your users experience a slow site, your SEO ranking drops, and you're stuck fixing it manually.

## The Solution

The tool runs a **3-phase verification loop**:

### Phase 1: Establish Baseline
Before touching code, the AI captures:
- Core Web Vitals (LCP, CLS, INP) from Google Analytics
- Slowest pages by URL
- Search rankings and CTR from Google Search Console

**This is the bar you can't regress below.**

### Phase 2: Write Code (Existing Loop)
You ask Claude Code to add a feature. It writes code, runs Lighthouse, and if it fails:
- Reads the error ("images are 2.3MB unoptimized")
- Identifies the fix ("add next/image, WebP, lazy loading")
- Refactors automatically
- Retries until 100%

### Phase 3: Validate Against Real Data
Once Lighthouse passes, the AI checks real user metrics:
- Did Core Web Vitals improve? ✅
- Did search CTR hold steady? ✅
- No new crawl errors? ✅

If everything passes → code commits. If regression → Claude fixes it first.

## Installation

### Quickstart (30 seconds)
Just want Lighthouse? Drop 3 files into your project:

```bash
curl -O https://raw.githubusercontent.com/dansinger93/AI-Coding-with-Speed-Guardrails-/main/CLAUDE.md
curl -O https://raw.githubusercontent.com/dansinger93/AI-Coding-with-Speed-Guardrails-/main/lighthouserc.js
mkdir -p scripts && curl -o scripts/check-speed.js https://raw.githubusercontent.com/dansinger93/AI-Coding-with-Speed-Guardrails-/main/scripts/check-speed.js
npm install -D @lhci/cli
```

Add to `package.json`:
```json
{
  "scripts": {
    "check-speed": "node scripts/check-speed.js"
  }
}
```

**Done.** Claude Code now enforces Lighthouse 100%.

### Full Power (5 minutes)
Want real user metrics too? One command:

```bash
bash <(curl -s https://raw.githubusercontent.com/dansinger93/AI-Coding-with-Speed-Guardrails-/main/setup.sh)
```

The script asks for your GA Property ID + GSC Site URL, installs MCP servers, configures Claude Code.

(First-time Google Cloud? There's a [step-by-step guide](https://github.com/dansinger93/AI-Coding-with-Speed-Guardrails-/blob/main/GOOGLE_CLOUD_SETUP.md))

## Example: Adding a Carousel

```
You: "Add a carousel with 50 product images"

Claude Code:
  ├─ Phase 1: Captures baseline (LCP=2.1s, CLS=0.08)
  │
  ├─ Phase 2: npm run check-speed
  │  ├─ Writes carousel with <img> tags
  │  ├─ Lighthouse: 34% (images 12MB)
  │  ├─ Refactors: next/image, WebP, lazy load
  │  ├─ Lighthouse: 87%
  │  ├─ Removes dead code, code-splits
  │  ├─ Lighthouse: 100% ✓
  │
  └─ Phase 3: Validates
     ├─ Current: LCP=1.9s (IMPROVED ✓)
     ├─ CLS=0.05 (STABLE ✓)
     └─ Code committed
```

No manual performance audits. No "fix it after ship." Just fast code, every time.

## Graceful Degradation

- **Just starting?** Use Option A (Lighthouse only) — zero config, works immediately
- **Have Google Cloud set up?** Use Option B (full stack) — GA + GSC validation
- **Add metrics later?** Switch anytime — same setup script works

## Why I Built This

I was using Claude Code daily, and it kept shipping technically correct code that was *slow*. Lighthouse would fail, Claude would read the error and fix it (great!), but sometimes real-world metrics told a different story.

Real users experienced Core Web Vitals degradation that synthetic tests missed. Search rankings dropped from unoptimized images. Crawl errors appeared in GSC.

I realized: **The AI is as good as its feedback loop.**

So I built a feedback loop that includes:
- ✅ Synthetic tests (Lighthouse)
- ✅ Real user data (GA)
- ✅ Search visibility (GSC)

Now when Claude Code writes code, it's validated against all three. If anything breaks, it fixes itself.

## Open Source

Everything is MIT licensed, fully open source, and ready to use.

GitHub: https://github.com/dansinger93/AI-Coding-with-Speed-Guardrails-

---

If you use Claude Code, Cursor, or GitHub Copilot, give it a star. And if you run into any issues or have ideas for extending it (Playwright tests, CI/CD integration, other validators), pull requests are welcome.

Let's stop shipping slow code. 🚀
