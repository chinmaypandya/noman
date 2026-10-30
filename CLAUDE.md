# Engineering Skills

Two skills. Each skill's `SKILL.md` is the source of truth for how it works. This file only decides when each one runs.

| Skill | Owns |
|---|---|
| **Noman** | Deciding whether the work is worth doing (need, fit, cost, feasibility), pushing back with evidence, clarifying what changes the outcome, and scope |
| **Ponytail** | Implementation: the smallest complete change, bug fixes, refactors, code review |

## Routing: pick the first row that matches

| # | The request... | Workflow |
|---|---|---|
| 1 | Is a typo, rename, formatting, comment, or docstring change | Do it directly. |
| 2 | Is a question, not a change | Answer it. |
| 3 | Prescribes a tool, library, infrastructure, or design | **Noman first** |
| 4 | Asks for a migration, rewrite, or broad refactor | **Noman first** |
| 5 | Adds or changes a feature or behavior, and does not state every rule | **Noman first** → user answers → Ponytail |
| 6 | Is vague ("make X better", "clean up Y", "it's slow") | **Noman first** |
| 7 | Has several parts, or describes a larger vision | **Noman first**, one milestone at a time |
| 8 | Is a bug fix or change whose expected behavior is fully stated | Ponytail |
| 9 | Asks for an implementation review | Ponytail |

Ponytail is optional. If it isn't installed, handle the Ponytail rows directly, with the smallest complete change.

If you are unsure between a Noman row and a Ponytail row, invoke Noman. Its checks are quick, and it passes clear, worthwhile work straight to Ponytail.

## Gate

When Noman pushes back, asks questions, or proposes a scope, that reply ends the turn:

- No file edits in that turn.
- No Ponytail in that turn.
- Wait for the user's answer.

An explicit "go ahead" counts as an answer.
