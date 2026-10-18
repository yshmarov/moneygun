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

The recorded revision means every commit through that point was classified, not that every changed file was copied. A review ends in one of three outcomes:

- **Adopt** when the behavior and contract are generic.
- **Adapt** when the production lesson is generic but EthicsPortal's model names, upload flow, deployment identity, or notification channel are not.
- **Exclude** when the change implements whistleblowing, legal/compliance content, or an EthicsPortal-only infrastructure decision.

The October 2026 review is the reference example. Moneygun adopted the runtime and dependency upgrades, session-token rotation safety, mandatory 2FA on platform administration, audit and AppSignal reporting for admin grants, SSO denial diagnostics, sudo fixes, CSP and rate-limit hardening, exact secret filtering, real Permissions-Policy headers, no-store tenant pages, upload scan recovery, metadata stripping by detected type, PDF revision removal, encrypted database backups, restore verification, Action Cable encryption, cron check-ins, CI cleanup, container limits, and dependency cooldowns. It adapted EthicsPortal's signed-ID fix by binding browser direct uploads to the authenticated user instead of disabling direct uploads, because Moneygun's Dropzone is a supported template component.

That review deliberately excluded EthicsPortal's per-blob evidence encryption and cross-region evidence mirror. They are coupled to reporter evidence, a maintained fork of `active_storage_encryption`, and an application-specific storage topology. Moneygun still protects its generic uploads with authorization, short-lived URLs, malware scanning, metadata removal, non-cacheable private responses, and encrypted database backups. Revisit the exclusion when the encryption package has a stable upstream release and a generic direct-upload ownership contract.

Never merge the EthicsPortal branch into Moneygun or copy an entire directory. The repositories have different products, schemas, routes, translations, and deployment identities. Copying is appropriate only for self-contained files that are genuinely identical; otherwise adapt and test the behavior.

Run the audit against a committed EthicsPortal revision. If the source checkout is dirty, the command reports that fact; do not copy those working-tree files. Review `git show <revision>:<path>` or a clean worktree so the recorded SHA is reproducible.

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
