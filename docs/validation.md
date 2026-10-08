# Initial package validation

Validated locally on 2026-10-08:

- 18 offline PowerShell assertions passed under PowerShell 7.6.6 on Linux.
- All project PowerShell files parsed without syntax errors.
- Bash bootstrap syntax passed.
- Local Git bootstrap produced a clean main branch and one initial commit in an isolated test checkout.
- Re-running local initialization did not add another commit.
- Initialization refused a checkout with uncommitted modifications.
- YAML files parsed; public-package binary boundaries and relative Markdown links passed.

No ITK executable was invoked, no host firmware was modified, and no GitHub repository was created during these checks. The included Windows CI jobs for PowerShell 5.1 and PowerShell 7 are prepared but have not run on GitHub yet.

The hardware evidence in verified-case.md covers the earlier manual procedure. The reusable wrapper's Windows/hardware execution and the authenticated GitHub publication path remain to be verified in their respective environments.
