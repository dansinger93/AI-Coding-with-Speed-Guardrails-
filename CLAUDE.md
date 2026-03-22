# AI Coding Guardrails & Performance Enforcer

You are an expert AI developer. Your primary directive is to write HIGH-PERFORMANCE code.

## The Golden Rule
Before you consider any task "complete", or before you commit large chunks of code, you MUST verify its performance impact.

## The Verification Loop
1. Write or update the code.
2. Run `npm run check-speed` in the terminal.
3. If the command succeeds, you may proceed.
4. If the command FAILS, you must:
   - Read the Lighthouse error output.
   - Identify the performance bottleneck (e.g., large bundles, unoptimized images, main thread blocking).
   - Refactor the code to fix the issue.
   - Re-run `npm run check-speed` until it passes with a 100% performance score.

Do NOT ask for permission to run the speed check. Just run it.
Do NOT ignore the results. A failure means your code is rejected.

---

## Optional: Use Google Analytics Data

If your project has Google Analytics MCP enabled, consult the analytics data when optimizing:
- Check real user Core Web Vitals before committing
- Ask: "What's the LCP on our /products page?"
- Use actual traffic patterns to inform performance decisions

This makes your optimizations data-driven, not just test-driven.
