# CLAUDE.md

Instructions for AI coding assistants (Claude Code, Cursor, Copilot, etc.)

## Project Overview

Moneygun is a Rails 8 multi-tenant SaaS boilerplate. Uses route-based multitenancy where resources are scoped under `/organizations/:id/...`.

## Commands

```bash
bin/setup                         # Initial setup
bin/dev                           # Development server

rails test:all                    # All tests
rails test test/models/user_test.rb:42  # Specific test

bundle exec rubocop -A            # Ruby linting
bundle exec erb_lint --lint-all -a  # ERB linting
i18n-tasks normalize              # Sort i18n keys
```

## Architecture

### Multi-tenancy

- Routes: `/organizations/:organization_id/resource/:id`
- `Current.organization` and `Current.membership` set via `Organizations::BaseController`
- Always scope queries: `Current.organization.projects` not `Project.all`

### Current Context

```ruby
Current.organization   # Current tenant
Current.membership     # User's membership in current org
Current.user           # Authenticated user
```

### Key Models

- **User**: Devise auth, can belong to multiple organizations
- **Organization**: The tenant, has subscriptions via Pay gem
- **Membership**: User-Organization join table with roles (`member`, `admin`)
- **Project**: Example org-scoped resource with obfuscated IDs (Sqids)

### Controller Pattern

Org-scoped controllers inherit from `Organizations::BaseController`:

```ruby
class Organizations::TasksController < Organizations::BaseController
  def index
    authorize Task
    @tasks = @organization.tasks
  end
end
```

### Authorization

Pundit with membership-based policies. `pundit_user` returns `Current.membership`:

```ruby
rails g pundit:policy resource_name
```

### Resource Association

Associate org-scoped resources with `membership`, not `user`:

```ruby
class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :membership
end
```

### Routes

Split into `config/routes/`:
- `users.rb` - User account routes
- `organizations.rb` - Org-scoped resources
- `admin.rb` - Avo admin panel routes

### Payments

Stripe via Pay gem. Plans in `config/settings.yml`. Webhook: `/pay/webhooks/stripe`

Use `before_action :require_subscription` for paywalled features.

### Frontend

- Tailwind CSS 4 + daisyUI 5
- Hotwire (Turbo + Stimulus)
- ViewComponent

## Conventions

- Thin controllers, rich models
- Always use `Current` context
- Never query without organization scope
- Use `ObfuscatesId` concern for public-facing IDs
