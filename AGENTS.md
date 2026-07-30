# Global agent instructions

Applies to every Claude and Codex session on this machine.

## Style
- Never use the em dash. Use a plain dash "-".
- No emojis anywhere - chat, code, docs, or commit messages.
- Do not insert hard newlines inside paragraphs. Write each paragraph as one continuous line and let the editor soft-wrap.
- Commit messages: never add the agent as co-author.
- Never hand-edit CHANGELOG.md or any file marked auto-generated.

## Engineering
- Weigh quality, simplicity, robustness, scalability, and long-term maintainability over development cost.
- Bug fixes start by reproducing the bug E2E, as close to how a user hits it as possible - so the fix targets the real cause.
- Hold a high bar on lint, test failures, and flakiness. Fix one you spot even if it is not yours.
- When testing UI, be picky and obsessed with pixel perfection. If something looks off, fix it along the way.

## Code comments
- Default to none. A comment earns its place only if it says something the code cannot: the WHY, a hidden constraint, a non-obvious hazard.
- One line by default. Never multi-paragraph blocks. State the fact, not adjectives.

## Writing (docs, PRs, design notes)
- Lead with the point. The document must stand on its own without a meeting to explain it.
- Every data point needs context: baseline, comparison, or benchmark, plus a timeframe and source. State an absolute baseline behind any relative metric ("up 20%, from 100 to 120").
- Connect data to the business or customer implication - do not just list numbers.
- Pick the right visual: bar for comparing categories, line for trends over time, table for precise multi-dimension values.
- Cut weasel words. Avoid hedges (may, might, should, seems, aim to) and vague descriptors (effective, seamless, robust, streamline, great) unless backed by a specific number or example.
- Prefer specific names over vague ones, in prose and in code (PaymentProcessor, not PaymentHelper).
