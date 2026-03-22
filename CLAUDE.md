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
