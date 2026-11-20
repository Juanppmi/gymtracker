# AGENTS.md

Read this file before every task and follow the flow below.

## Branches

- `main` changes only after the user tests. Push and merge to `main` stay with the user.
- `development` is the delivery branch. Every task ends here.
- `type/task` is the working branch, created from an up-to-date `development`.

If `development` does not exist yet, create it from `main`.

## Flow

1. If the task mixes topics or the type is unclear, ask before opening the issue.
2. Open an issue with `gh issue create`. Short title, in English. Body: context, done criteria, and how to test.
3. Update `development` and create the branch `type/task-in-kebab-case`.
4. Do only what the issue asks.
5. One commit. The subject equals the branch name. In the body, say why and include `Closes #<number>`.
6. Run the project tests when they exist. If they fail, do not merge.
7. Merge the branch into `development` with `--no-ff` and push only `development`.
8. Tell the user what to test. The user tests `development` and, if it is right, brings it to `main` with a merge, without squash.

`Closes #<number>` closes the issue when the commit reaches `main`. The issue stays open while `development` is being tested.

## Name

Lowercase, hyphens, no accents. The prefix is a type from the table.

```text
fix/exercise-list-screen-stuck
```

`issue` is not a type. A stuck screen is a `fix`. The commit subject repeats the branch name. Do not mix types in the same commit.

## Types

| Prefix | Meaning | When to use |
| --- | --- | --- |
| feat | Feature | Add a new feature |
| fix | Fix | Fix a bug |
| chore | Chore | Maintenance that does not change features |
| docs | Documentation | Change documentation |
| style | Style | Formatting, whitespace, semicolons, and similar |
| refactor | Refactoring | Improve the code without changing its behavior |
| test | Tests | Add or change tests |
| perf | Performance | Improve performance |
| build | Build | Change the build process or dependencies |
| ci | Continuous Integration | Change CI/CD pipelines and configuration |
| revert | Revert | Undo a previous commit |

## Language

- Issues, commits, documentation, code, comments, tests, CI, and messages to the user are in English.
- Text on screen in the app is Portuguese or English, chosen from the phone OS language.
- A Portuguese OS locale (`pt`, `pt-BR`, `pt-PT`) uses Portuguese. An English OS locale uses English. Any other OS language uses English.
- Every user-visible string goes through localization. Do not hardcode one language in the UI.

## Limits

- One issue, one branch, one commit, one merge into `development`.
- Do not change `main`.
- Do not use force push, amend, or `--no-verify`.
- Do not commit a secret, `.env`, or credential.
- Do not open a pull request unless the user asks. Delivery is the merge into `development`.
- If the project cannot run tests yet, say that in the issue instead of inventing a result.
