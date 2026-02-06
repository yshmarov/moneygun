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

## Accessibility

Based on [Accessibility essentials every front-end developer should know](https://martijnhols.nl/blog/accessibility-essentials-every-front-end-developer-should-know).

### Semantic HTML

- Never use `<div>` or `<tr>` with `onclick` for interactive elements. Use `<a>` for navigation and `<button>` for actions.
- Use proper list elements (`<ul>/<ol>` with `<li>`). Don't misuse `<dl>` without `<dt>/<dd>` pairs.
- Use semantic landmarks: `<main>`, `<nav>`, `<header>`, `<footer>`, `<aside>`, `<section>`.

### Images & Icons

- All `<img>` tags must have an `alt` attribute. Use `alt=""` only for purely decorative images.
- Decorative SVGs and icons must have `aria-hidden="true"` (the `nav_link` helper and `TabsComponent` handle this automatically).
- Emoji icons used as meaningful indicators need `role="img"` and `aria-label` (see `privacy_setting_icon`).
- Don't use `alt` on `<span>` elements — it's not a valid attribute. Use `aria-label` instead.

### Focus & Keyboard Navigation

- Never remove focus indicators entirely. The app uses `:focus` with a primary-color glow effect.
- All interactive elements must be keyboard-accessible (focusable, activatable with Enter/Space).
- Skip navigation links are present in all layouts — maintain these when adding new layouts.
- Modals must restore focus to the trigger element on close (handled by `dialog_controller.js`).

### ARIA

- Use `aria-label` on buttons/controls that have no visible text (e.g., icon-only buttons).
- Use `role="alert"` on error messages and flash notifications so screen readers announce them.
- Use `aria-labelledby` to associate modal titles with `<dialog>` elements.
- Use `aria-hidden="true"` on decorative elements that duplicate adjacent text labels.

### Forms

- All form inputs must have associated labels. Use SimpleForm which generates labels automatically.
- The language picker uses a `<label class="sr-only">` for its `<select>`.
- Use `autocomplete` attributes on login/registration fields.

### Motion & Zoom

- `prefers-reduced-motion: reduce` is respected globally — all animations and transitions are disabled.
- Never restrict zoom (`user-scalable=0`, `maximum-scale=1`) in regular mobile browsers (WCAG 1.4.4). Only restrict in native app shells (`hotwire_native_app?`).

### JavaScript

- Use Stimulus controllers instead of inline event handlers (`onclick`, `onchange`).
- The `locale_picker_controller.js` handles language switching; `dialog_controller.js` handles modal focus management.

## Git Workflow

- **Never commit directly to main/master** - always create a feature branch
- **Always create a PR** for changes
- **Do not merge PRs yourself** - wait for the user to review and merge

## AI Learnings

### Pundit Authorization

- To enforce authorization on all actions: `after_action :verify_authorized` in base controller
- To skip verification for specific controllers: `skip_after_action :verify_authorized`
- Do NOT use `skip_verify_authorized` or `skip_authorization` at the class level - these don't exist
- The `authorize` method must be called inside each action, or via a `before_action` callback

### ConnectedAccount Model

- The `name` attribute is computed from `payload` JSON (`payload&.dig("info", "name")`), not a database column
- Cannot use `pick(:name)` or similar SQL queries for this field
- When eager loading with `includes(:connected_accounts)`, use `connected_accounts.first&.name`

### Organization Membership Checks

- Use `memberships.exists?(user: user)` instead of `users.include?(user)` for efficiency
- The latter loads all users into memory; the former uses SQL EXISTS

### Markdown Sanitization

- When using Redcarpet with `filter_html: false`, always wrap output with Rails `sanitize`
- Safe tags for content with embeds: `%w[p h1 h2 h3 h4 h5 h6 ul ol li a code pre blockquote strong em img iframe div span br hr table thead tbody tr th td]`
- Safe attributes: `%w[href src alt title class id width height frameborder allowfullscreen]`
