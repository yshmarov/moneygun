# Linting and audits

`bin/lint` is the single source of truth for checks that do not need a database:

```bash
bin/lint
bin/lint --fix
```

It runs:

- RuboCop for Ruby style and correctness
- Prettier 3.9.6 for formatting
- Brakeman for Rails security analysis
- Herb for ERB analysis
- i18n-tasks for missing, invalid, and unnormalized translations
- bundler-audit for vulnerable Ruby dependencies
- importmap audit for vulnerable JavaScript dependencies

`--fix` applies RuboCop autocorrections, Prettier formatting, and i18n normalization. Security and dependency checks remain read-only.

Configuration lives in `.rubocop.yml`, `.prettierrc`, `.prettierignore`, and `config/i18n-tasks.yml`. Prettier is pinned in `bin/lint`; an unpinned `npx prettier` may produce different output as new releases appear.

## Full verification

Run the same application gate used by maintainers before proposing a change:

```bash
bin/ci
```

This prepares the app, runs `bin/lint`, checks eager loading and the database schema, then runs unit, system, and seed tests. Hosted CI keeps lint and test jobs separate so they can run in parallel. It additionally scans the pushed commit range for leaked secrets.

The local gate also runs `bin/gitleaks-audit`. Install Gitleaks before the first full run (`brew install gitleaks` on macOS, or use the installation method documented by Gitleaks for your platform). The script scans tracked and nonignored untracked files plus `origin/main..HEAD`, so a secret cannot hide in an uncommitted file that ordinary history-only scanning would miss.

The daily dependency-audit workflow reruns advisory scans even when the repository has had no new commits. Dependabot proposes weekly Bundler and GitHub Actions updates.
