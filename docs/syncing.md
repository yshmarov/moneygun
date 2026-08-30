# Keeping Moneygun and its descendants current

Moneygun is the reusable Rails SaaS foundation. EthicsPortal is a production application that exercises it and is a source of proven generic patterns; it is not a Git parent of Moneygun, and its whistleblowing domain is deliberately excluded.

## Review production learnings from EthicsPortal

Keep both repositories checked out. From Moneygun, run:

```bash
bin/sync-audit ../../ethicsportal.eu
```

Or point to any checkout:

```bash
ETHICSPORTAL_PATH=/path/to/ethicsportal.eu bin/sync-audit
```

The command reads `config/ethicsportal_sync.yml`, shows commits made after the last reviewed EthicsPortal revision, warns when the source checkout has uncommitted changes, and classifies the maintained path inventory as `compare`, `adapt`, or `exclude`.

After reviewing every new source commit, port generic behavior with Moneygun's names and contracts, run `bin/ci`, then update `last_reviewed_revision` to the exact EthicsPortal commit reviewed. `bin/sync-audit --check` exits non-zero when the recorded revision is behind the source checkout, so it can be used in a local maintenance check.

Never merge the EthicsPortal branch into Moneygun or copy an entire directory. The repositories have different products, schemas, routes, translations, and deployment identities. Copying is appropriate only for self-contained files that are genuinely identical; otherwise adapt and test the behavior.

The `website/` exclusion refers to EthicsPortal's product content, localization matrix, directory integrations, and compliance pages. Moneygun owns its own small Hugo skeleton and may adopt generic build or deployment improvements without copying that content.

## Pull Moneygun updates into an application

An application built from Moneygun should retain its own `origin` and add Moneygun as `moneygun`:

```bash
git remote add moneygun https://github.com/yshmarov/moneygun.git
git fetch moneygun
git switch -c maintenance/moneygun-sync
git merge --no-commit --no-ff moneygun/main
```

Resolve conflicts in favor of the application's business behavior while retaining generic security, lifecycle, CI, and operations improvements. Before committing, review the staged result and run the application's full suite:

```bash
git diff --staged
bin/ci
git commit
git push -u origin HEAD
```

Open a pull request in the application repository. Do not push the merge directly to its default branch unless that repository's shipping policy explicitly calls for it.

## What stays application-owned

Each application owns its business models and workflows, tenant-specific authorization decisions, product copy, pricing, legal content, data-retention rules, hostnames, credentials, external service activation, and smoke-test scenarios. Moneygun supplies configurable primitives and safe defaults; a green Moneygun suite does not prove a downstream deployment is configured or reachable.
