# Twitter Thread: AI Performance Guardrails

## Main Thread

**Tweet 1:**
I got tired of Claude Code shipping slow code.

So I built a tool that forces it to validate against 3 things:
- Lighthouse 100% ✅
- Real user data from Google Analytics ✅
- Search health from Google Search Console ✅

If ANY fail, the AI refactors itself until it passes.

GitHub: https://github.com/dansinger93/AI-Coding-with-Speed-Guardrails-

---

**Tweet 2:**
The 3-phase loop:

**Phase 1:** AI grabs your baseline metrics (CWV, search rankings, crawl errors)

**Phase 2:** You ask it to build something → it writes code → runs Lighthouse → fails? It reads the error and refactors automatically until 100%

**Phase 3:** Validates against real user data before committing

---

**Tweet 3:**
Example: "Add a carousel with 50 product images"

Claude Code:
❌ First try: Lighthouse 34% (images 12MB)
🔄 Refactors: next/image + WebP + lazy load
⚠️ Second try: Lighthouse 87%
🔄 Removes dead code, code-splits
✅ Third try: Lighthouse 100% + CWV improved
Code committed.

---

**Tweet 4:**
Why it matters:

A bloated bundle passes your local tests. Unoptimized images look fine in dev. Third-party scripts don't show up until production.

Then your users get a slow site, your SEO tanks, and you're stuck fixing it.

This prevents that entirely.

---

**Tweet 5:**
Setup is dead simple:

Option A (Lighthouse only): 3 curl commands
Option B (Full stack with GA + GSC): One bash script

Both work with Claude Code, Cursor, GitHub Copilot — any AI assistant.

Graceful degradation: works without analytics, gets better with it.

---

**Tweet 6:**
It's open source (MIT), fully distributable, and production-ready.

If you use AI for coding, you need this.

⭐ Star it on GitHub if it resonates

v1.0.0 just shipped 🚀

---

## Hashtags to Use
#AI #WebDevelopment #Performance #Lighthouse #DevTools #OpenSource #ClaudeAI #WebPerf #JavaScript #NextJS

## Best Time to Post
Tuesday-Thursday, 9-11 AM Pacific (when developers are scrolling)
