# Engineering Skills

Two skills. Each skill's `SKILL.md` is the source of truth for how it works. This file only decides when each one runs.

| Skill | Owns |
|---|---|
| **Noman** | Deciding whether to proceed, clarify, challenge, or stop (need, fit, cost, feasibility, risk), pushing back with evidence, clarifying what changes the outcome, and scope |
| **Ponytail** | Implementation: the smallest complete change, bug fixes, refactors, code review |

## Routing: pick the first row that matches

| # | The request... | Workflow |
|---|---|---|
| 1 | Is a typo, rename, formatting, comment, or docstring change | Do it directly. |
| 2 | Is a question, or asks to investigate without changing anything | Answer or investigate directly, read-only. No skills. |
| 3 | Deletes, overwrites, or drops anything: files, folders, caches, branches, or records and rows inside a file or database | **Noman first** |
| 4 | Weakens a safeguard or treats a symptom (disable auth or validation, skip tests or verification, change a test's expected output, raise a timeout, suppress an error, add retries) | **Noman first** |
| 5 | Prescribes a tool, library, infrastructure, pattern, or design | **Noman first** |
| 6 | Asks for a migration, rewrite, or broad refactor | **Noman first** |
| 7 | Adds or changes a feature or behavior, and does not state every rule | **Noman first** → user answers → Ponytail |
| 8 | Is vague ("make X better", "clean up Y", "it's slow") | **Noman first** |
| 9 | Has several parts, or describes a larger vision | **Noman first**, one milestone at a time |
| 10 | Is a bug fix or change whose expected behavior is fully stated | Ponytail |
| 11 | Asks for an implementation review | Ponytail |

Ponytail is optional. If it isn't installed, handle the Ponytail rows directly, with the smallest complete change.

If you are unsure between a Noman row and a Ponytail row, invoke Noman. Its checks are quick, and it passes clear, worthwhile work straight to Ponytail.

## Always, even when no skill runs

- **Destructive actions:** before deleting or overwriting files, folders, caches, branches, or records, list the exact targets and get confirmation. Never delete production or irreversible data without a backup and explicit confirmation, even if asked not to ask.
- **"No" is final.** Don't do what the user declined.

## Gate

When Noman pushes back, asks questions, or proposes a scope, it doesn't act on the disputed part in that turn:

- No file edits for it in that turn.
- No Ponytail for it in that turn.
- Wait for the user's answer.
- A clear, independent part of the same request can be done now.

An explicit "go ahead" counts as an answer. An explicit "no" ends the proposal.
