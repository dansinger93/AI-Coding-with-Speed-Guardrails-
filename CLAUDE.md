# AI Coding Guardrails & Performance Enforcer

You are an expert AI developer. Your primary directive is to write HIGH-PERFORMANCE code
that is validated against both synthetic benchmarks AND real user data.

## The Golden Rule

Before you consider any task "complete", you MUST complete all three phases below.
Do not skip phases. Do not ask for permission. Just execute.

---

## Phase 1 — Establish Baseline (Before Writing Code)

Before writing or modifying any code, establish a performance baseline:

1. Run: `node scripts/check-analytics.js baseline`
2. This script will:
   - If GA/GSC are configured: query Core Web Vitals, top slowest pages, search rankings,
     CTR, impressions, and crawl errors from the last 28 days, then save to `.perf-baseline.json`
   - If GA/GSC are NOT configured: skip gracefully, print a notice, continue to Phase 2
3. If `.perf-baseline.json` was created, read it and keep these numbers in mind.
   They are the bar you must not regress below.

**Key baseline metrics to note if present:**
- LCP, CLS, INP from GA (real user Core Web Vitals — the user experience you're defending)
- Top 5 slowest pages by URL from GA (which pages matter most)
- Top 10 search queries by impressions and CTR from GSC (your traffic drivers)
- Any active crawl errors or indexing failures from GSC (SEO blockers)

---

## Phase 2 — Write Code and Enforce Lighthouse (The Existing Loop)

1. Write or update the code.
2. Run: `npm run check-speed` in the terminal.
3. If the command succeeds, proceed to Phase 3.
4. If the command FAILS:
   - Read the Lighthouse error output carefully.
   - Identify the bottleneck (large bundles, unoptimized images, main thread blocking,
     render-blocking resources, slow third-party scripts, etc.).
   - Refactor the code to fix the issue. Use the Lighthouse suggestions as a guide.
   - Re-run: `npm run check-speed` until it passes with a 100% performance score.

Do NOT ask for permission to run the speed check. Just run it.
Do NOT ignore failures. A failed Lighthouse check means your code is rejected.

---

## Performance Playbook — Common Bottlenecks and Fixes

### Total Blocking Time (TBT) — The #1 Killer

TBT fails because JavaScript runs on the main thread during page load. The biggest offenders:

**Animation libraries in shared components are the most dangerous.**
A library like Framer Motion (~100KB) loaded in a Navbar or Layout component forces its
entire bundle into the critical-path shared chunk that loads on EVERY page. Even if you
only used it for a simple fade-in, the full library ships.

Fix: Replace JS-driven animations with CSS animations. They run on the compositor thread
(zero main thread cost) and have no bundle weight.

```css
/* globals.css — define once, use everywhere */
@keyframes fade-up {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

```tsx
// Before (Framer Motion — blocks main thread, adds ~100KB)
<motion.div initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }}>

// After (CSS — zero JS cost)
<div style={{ animation: "fade-up 0.6s cubic-bezier(0.22,1,0.36,1) both" }}>
```

For interactive enter/exit animations (dropdowns, toasts, modals), use Tailwind's
`animate-in` utilities: `fade-in-0 slide-in-from-bottom-4 zoom-in-95 duration-200`.

**How to identify which chunk is causing TBT:**
1. In the Lighthouse report, note the slow chunk filenames (e.g. `abc123.js`)
2. Fetch the chunk from production: `curl https://your-site.com/_next/static/chunks/abc123.js`
3. Search for library identifiers: `framer`, `AnimatePresence`, `motion`, `gsap`, etc.
4. Remove that library from the component(s) listed in that chunk

---

### LCP (Largest Contentful Paint)

**CSS `background-image` is invisible to the preload scanner.**
If your hero/above-fold image is set via CSS `background-image`, the browser cannot
discover it until CSS is parsed — too late to preload. Use `<img>` or Next.js `<Image>`.

```tsx
// Wrong — browser discovers this too late
<div style={{ backgroundImage: "url('/hero.webp')" }} />

// Right — preload scanner finds it immediately
<Image src="/hero.webp" fetchPriority="high" preload={true} alt="" fill />
```

**Next.js 16+: `priority` prop is deprecated.**
Use `fetchPriority="high"` + `preload={true}` instead.
```tsx
// Next.js 15 and earlier
<Image src="..." priority />

// Next.js 16+
<Image src="..." fetchPriority="high" preload={true} />
```

**Image delivery savings add up fast.**
Lighthouse's "Properly size images" audit flags exact savings. A background image
at opacity 0.1 can be compressed to quality 50 with no visible difference.
Always convert to WebP and resize to actual display dimensions.

**Bypass the image optimization pipeline for static assets on self-hosted deployments.**
`/_next/image` runs server-side processing on every request. On non-Vercel hosting
this adds latency on every image load. Pre-optimize images and use `unoptimized` on `<Image>`:
```tsx
<Image src="/already-optimized.webp" unoptimized ... />
```

---

### Testing: Production URL vs Localhost

Always test against the production URL when one is available. Localhost scores can
differ from production by 10-30 points because:
- No CDN (missing compression, HTTP/2, edge caching)
- Missing Brotli/gzip from production server
- Dev mode bundles are larger and unminified
- Network conditions differ

To test production: set `url` in `lighthouserc.js` to your live URL and remove
`startServerCommand`. The `check-speed.js` script skips the build step automatically.

---

### Accessibility

**Color contrast is the most common failure.**
`text-foreground/40` (opacity modifier) typically produces ~2.5:1 — well below WCAG AA (4.5:1).
Use a named color with a known contrast ratio instead of opacity-modified text.

**Check contrast before shipping:**
```
#111827 at 40% opacity on white ≈ 2.5:1  — FAILS
#78716C (muted gray) on white   ≈ 5.1:1  — PASSES
```

---

## Phase 3 — Validate Against Real User Data (After Lighthouse Passes)

Once Lighthouse reports 100%, validate that your changes do not introduce regressions
in real user metrics:

1. Run: `node scripts/check-analytics.js validate`
2. This script compares current GA/GSC data against `.perf-baseline.json` saved in Phase 1.
3. Review the comparison output:
   - If GA/GSC are NOT configured: skip gracefully, print a notice, task is complete.
   - If metrics have IMPROVED or HELD STEADY: task is complete. Commit the code.
   - If metrics show a REGRESSION (e.g., Core Web Vitals worsened, CTR dropped, new crawl
     errors appeared): treat this as a failure. Investigate which code change caused it,
     refactor to fix the regression, then re-run Phase 3 until validation passes.

Validation does not block on Lighthouse — it gates on real user data.

---

## Graceful Degradation

All three phases are designed to work even when GA or GSC are not configured.

If `scripts/check-analytics.js` prints "GA/GSC not configured — skipping analytics phase",
that is acceptable. The Lighthouse loop (Phase 2) always runs regardless, ensuring this
tool works on day one without any analytics setup.

**To enable GA/GSC integration:** run `bash setup.sh` in the project root.
The setup script will guide you through credential configuration and MCP server installation.

---

## Optional: Use Google Analytics Data in Conversation

If your project has Google Analytics and Search Console MCP servers enabled
(installed by `setup.sh`), you can ask Claude Code conversational questions about your metrics:
- "What are the top 10 queries driving traffic this week?"
- "Which pages have the lowest CTR?"
- "Are there any active crawl errors in GSC?"

These queries do NOT affect the automated 3-phase loop — they are bonus context for decision-making.
The loop runs on `.perf-baseline.json` regardless of whether you ask questions.
