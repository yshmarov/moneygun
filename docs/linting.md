# Linting

## Tools Overview

- **RuboCop**: Lints Ruby (`.rb`) files
- **erb_lint**: Lints ERB (`.html.erb`) templates, uses RuboCop for Ruby code within templates
- **Herb LSP**: Provides real-time ERB diagnostics and formatting in VS Code
- **Prettier**: Formats all file types (Ruby, JavaScript, JSON, etc.) with consistent style

### Required Extensions

Install these VS Code extensions (recommended in `.vscode/extensions.json`):

- `esbenp.prettier-vscode` - Prettier formatter
- `marcoroth.herb-lsp` - Herb Language Server for ERB

## Commands

```bash
# Ruby files
# Lint
bin/rubocop
# Auto-fix
bin/rubocop -a

# ERB templates
# Lint
bin/erb_lint --lint-all
# Auto-fix
bin/erb_lint --lint-all -a
```

## Configuration Files

- `.rubocop.yml` - RuboCop rules for Ruby files
- `.erb_lint.yml` - erb_lint rules (inherits from `.rubocop.yml`)
- `.prettierrc` - Prettier formatting rules
- `.prettierignore` - Files to exclude from Prettier

## CI Integration

Linting runs automatically in CI on every pull request and push to main:

- RuboCop checks all Ruby files
- erb_lint checks all ERB templates

Both must pass for CI to succeed.
