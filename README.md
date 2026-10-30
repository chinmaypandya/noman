# noman

**noman**: a Claude Code skill that works like a pragmatic senior engineer, not a yes-man.
Before it writes code, it checks the request against your codebase:

- Is this needed?
- Does the code already do it?
- Is it worth what it costs?

When the answer is no, it says so with evidence and offers the smaller option. When the answer is yes, it asks only what changes the outcome, then ships the smallest change that works.

```bash
curl -fsSL https://raw.githubusercontent.com/chinmaypandya/noman/main/install.sh | bash
```

Run it from your project root. It installs noman together with [ponytail](#about-ponytail), or noman alone with `--no-ponytail`. [What it changes](#install).

## The problem

Coding agents say yes to everything. Ask one to:

- *"migrate all 10 handlers to pydantic"* because one handler missed a check, and it rewrites 12 files and adds a dependency;
- *"build a payment-provider plugin system"* for your one provider, and it builds a base class, a registry and a config loader;
- *"make refunds better"*, and it guesses which problem you meant and builds that.

The code usually works. The trouble is that nobody asked whether it should exist.

## What noman does

```
request ─▶ inspect code ─▶ need · fit · cost · feasibility ─┬─ fails ─▶ push back with evidence ─┐
                                                             └─ passes ─▶ unclear? ask ≤5 ─────────┤
                                                                          clear?  build ◀── answer ─┘
```

| Check | Question | Typical pushback |
|---|---|---|
| **Need** | Is the problem real, and present now? | "Do we have the scale or the consumers that need pub/sub yet?" |
| **Fit** | Does the existing code already solve it? | "Checkout already takes a payment function, so no plugin system is needed." |
| **Cost vs. value** | Is the change proportionate? | "This touches 10 files to fix one missing check. Why is that worth it?" |
| **Feasibility** | Can it work here as asked? | "This would break the existing `Store(...)` contract." |

Rules it follows:

- **Evidence, not taste.** Every pushback names the file, the function, or the number of files the change would touch.
- **Stop and wait.** A reply that pushes back or asks a question edits nothing. You answer first.
- **Not contrarian.** It doesn't push back on clear, proportionate requests, or a second time once you've given a reason.
- **Only material questions.** Money, eligibility, limits, reversals, time, concurrency, interfaces, data, scope. It decides the rest itself and states its assumptions.
- **Large work becomes milestones.** It proposes the first one and builds only that.
- **No redundant code or tests.** One test per new behavior. No tests for trivial accessors.

### What it looks like

> **You:** refund_line crashed on a request with no sku. Manual validation is error-prone, so migrate all 10 handlers to pydantic.
>
> **noman:**
> **Concern:** Need and cost. The crash is a narrow bug, and the migration is a large change to fix it.
> **Evidence:** `refund_line.py` is the only handler with no `sku` check. The other 9 already validate. Migrating touches 10 files, adds pydantic, and its lax mode would coerce `"1"` to `1`, which changes API behavior.
> **Smaller option:** Add the missing check to `refund_line`: about 4 lines in one file, plus one test.
> **Question:** Do you want the migration itself, beyond the crash fix?

*(Condensed from an actual benchmark run. The full text is in [the benchmark](eval/results/2026-10-30.md#same-request-two-engineers).)*

## Benchmark

Measured on Claude Haiku 5.5, using five complex real-world requests against a demo service. Each setup had 10 runs, with a simulated product owner, hidden acceptance tests and a blind judge.

| | No skills | **noman only** | **noman + ponytail** |
|---|:-:|:-:|:-:|
| Pushed back when it should | 2 / 6 | **6 / 6** | **6 / 6** |
| Built without fuss when it should (controls) | 4 / 4 | 3 / 4 | 3 / 4 |
| Hidden acceptance tests passing | 10 / 10 | 10 / 10 | 10 / 10 |
| Source lines added | 621 | 186 (−70%) | **116 (−81%)** |
| Test lines added | 379 | 192 (−49%) | **115 (−70%)** |
| Redundant tests | 20 | 3 | **0** |
| Output tokens (median) | 9.9k | 8.1k | **6.2k** |
| Cost (10 runs) | $0.148 | $0.177 | $0.164 |

- **noman makes the decision.** It gets the same pushback with or without ponytail.
- **ponytail keeps the build small,** cutting the remaining code by about 40%.
- **On everyday requests** (trivial fixes, bugs, vague asks, multi-part projects), both noman setups scored 2.00/2, against 1.13 with no skills. Neither added any overhead on trivial work.

> *"One handler crashed on a missing field, migrate all 10 handlers to pydantic."*
> **No skills:** migrated 12 files and added a dependency. **noman:** pointed out that only `refund_line` lacked the check, then fixed it in 4 lines, with or without ponytail.

**[Full benchmark, with method, excerpts and caveats →](eval/results/2026-10-30.md)**

## About ponytail

[Ponytail](https://github.com/DietrichGebert/ponytail) is **not our skill**. It is written and owned by [DietrichGebert](https://github.com/DietrichGebert), and its slogan is "the best code is the code you never wrote". It makes the agent take the smallest change that fully solves the task.

This repo ships an unmodified copy of its `SKILL.md` under its MIT license (see [`skills/ponytail/`](skills/ponytail/NOTICE.md)), only because noman was benchmarked with it. noman decides **whether and what** to build; ponytail keeps **how** it's built small. noman works without it (`--no-ponytail`). For ponytail itself, its plugin and updates, use [the original repo](https://github.com/DietrichGebert/ponytail).

## Install

From your project root:

```bash
# noman + ponytail (recommended, the benchmarked setup)
curl -fsSL https://raw.githubusercontent.com/chinmaypandya/noman/main/install.sh | bash

# noman only
curl -fsSL https://raw.githubusercontent.com/chinmaypandya/noman/main/install.sh | bash -s -- --no-ponytail
```

It will:

| Target | If it exists | If not |
|---|---|---|
| `.claude/skills/noman` (and `ponytail` unless `--no-ponytail`) | Replaces just those; your other skills are untouched | Creates `.claude/skills/` |
| `CLAUDE.md` | Adds the routing rules between `<!-- noman:start/end -->` markers; your content is untouched | Creates it |

Re-running updates the block in place and never duplicates it. `PONYTAIL=0` works the same way as `--no-ponytail`. Read [`install.sh`](install.sh) before piping it to a shell; it is about 80 lines.

From a clone: `git clone https://github.com/chinmaypandya/noman && cd your-project && bash ../noman/install.sh [--no-ponytail]`

To remove: delete the skill folders and the marked block in `CLAUDE.md`.

## Use

Describe the work. `CLAUDE.md` routes the request:

| You ask for | What happens |
|---|---|
| A typo, rename, or comment change | Done directly |
| A tool, infrastructure, a migration, or a broad refactor | **noman** checks need, fit, cost and feasibility, and pushes back with evidence if it isn't worth it |
| A feature with unstated rules, a vague request, or a multi-part project | **noman** asks only what changes the outcome, or proposes milestones, then waits |
| A fully specified bug fix or change | **ponytail** makes the smallest complete change, or Claude does it directly without ponytail |

When noman pushes back or asks, it stops and waits for your answer before editing anything.

## Layout

```
skills/
  noman/       pragmatic, not a yes-man: need, fit, cost, feasibility, clarification
  ponytail/    smallest complete change (optional, third-party: DietrichGebert/ponytail)
CLAUDE.md      routing rules and the stop-and-wait gate
install.sh     installer (--no-ponytail to skip ponytail)
eval/results/  dated benchmark results
```

## License

MIT. `skills/ponytail/` is © DietrichGebert, MIT. See [its LICENSE](skills/ponytail/LICENSE).
