# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Moneygun is a multi-tenant SaaS boilerplate built with Ruby on Rails 8. It uses route-based multitenancy where resources are scoped under `/organizations/:id/...` rather than subdomains or `user.organization_id`.

## Common Commands

```bash
# Setup
bin/setup

# Development server (runs web, css, stripe webhooks, background jobs)
bin/dev

# Run all tests
rails test:all

# Run a single test file
rails test test/models/user_test.rb

# Run a specific test by line number
rails test test/models/user_test.rb:42

# Linting
bundle exec rubocop -A          # Ruby
bundle exec erb_lint --lint-all -a  # ERB

# Sort i18n keys
i18n-tasks normalize
```

## Architecture

### Multi-tenancy Pattern

Resources are nested under organizations using route-based multitenancy:
- Routes: `/organizations/:organization_id/projects/:id`
- `Current.organization` and `Current.membership` are set via `Organizations::BaseController`
- Pundit policies receive `Current.membership` as the user context (see `pundit_user` method)

### Key Models

- **User**: Devise authentication, can belong to multiple organizations
- **Organization**: The tenant; includes concerns for Billing, Multitenancy, Transfer, Logo, Community
- **Membership**: Join table between User and Organization with roles (`member`, `admin`)
- **Project**: Example organization-scoped resource

### Resource Association Pattern

Always associate organization-scoped resources with `membership` instead of `user`:

```ruby
# Correct
class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :membership
end
```

### Controller Inheritance

Organization-scoped controllers inherit from `Organizations::BaseController`, which:
- Sets `@organization` from `current_user.organizations`
- Sets `Current.membership` and `Current.organization`
- Provides `require_subscription` for paywalled features

### Routes Structure

Routes are split into separate files in `config/routes/`:
- `users.rb` - User account routes
- `organizations.rb` - Organization-scoped resources
- `admin.rb` - Admin panel routes

### Authorization

Uses Pundit with membership-based policies. Generate policies with:
```bash
rails g pundit:policy resource_name
```

### Payments

Stripe subscriptions via Pay gem. Plans configured in `config/settings.yml`. Webhook endpoint: `/pay/webhooks/stripe`

### Admin Panel

Avo admin panel at `/avo`. Resources defined in `app/avo/resources/`.

### Frontend

- Tailwind CSS 4 with daisyUI 5 components
- Hotwire (Turbo + Stimulus)
- ViewComponent for reusable UI components

### Generating Nested Resources

```bash
rails generate nested_scaffold organization/resource_name field:type
```
