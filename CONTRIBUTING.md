# Contributing to Moneygun

Thanks for your interest in contributing! Here's how to get started.

## Development Setup

1. Fork and clone the repo
2. Run `bin/setup` to install dependencies and set up the database
3. Run `bin/dev` to start the development server

See [Getting Started](docs/getting-started.md) for detailed setup instructions.

## Making Changes

1. Create a feature branch from `main`
2. Make your changes
3. Run the test suite: `rails test:all`
4. Run linters: `bundle exec rubocop -A && bundle exec erb_lint --lint-all -a`
5. Push and open a pull request

## Code Conventions

- **Thin controllers, rich models** - business logic belongs in models
- **Always scope to organization** - use `Current.organization.resources`, never `Resource.all`
- **Associate with membership** - org-scoped resources belong to `membership`, not `user`
- **Pundit for authorization** - generate policies with `rails g pundit:policy resource_name`

See [Development Guide](docs/development.md) for more details.

## Pull Requests

- Keep PRs focused on a single change
- Include tests for new features and bug fixes
- Make sure CI passes (linting + tests)
- Describe what changed and why in the PR description

## Reporting Bugs

Open an issue with:

- Steps to reproduce
- Expected vs actual behavior
- Ruby/Rails version

## Feature Requests

Open an issue describing the use case and proposed solution. Discussion before implementation helps avoid wasted effort.
