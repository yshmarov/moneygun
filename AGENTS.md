# Moneygun - AI Agent Instructions

This file provides guidance to AI coding agents working with this repository.

## What is Moneygun?

Moneygun is a Rails 8 SaaS boilerplate for building multi-tenant applications. It provides a production-ready foundation with:

- **Multi-tenant Architecture**: Route-based organization management
- **Authentication**: Devise with OAuth (Google, GitHub)
- **Authorization**: Pundit policies
- **Subscription Management**: Stripe payments via Pay gem
- **Team Management**: Organizations, memberships, invitations, role management
- **Modern UI**: Tailwind CSS with daisyUI components

## Architecture Overview

### Multi-Tenancy

Moneygun uses **route-based multi-tenancy**:

- URLs: `/organizations/:id/projects/:id`
- All resources are scoped to an organization
- Users can belong to multiple organizations
- Each organization has its own context

**Key Insight**: Unlike subdomain-based multi-tenancy, route-based allows users to have multiple organizations open in different browser tabs.

### Current Context Pattern

The `Current` class provides request-scoped context:

```ruby
Current.organization  # Current organization in context
Current.membership   # Current user's membership in the organization
Current.user         # Current authenticated user (via membership)
Current.organizations # All organizations the user belongs to
```

**Important**: Always scope queries to `Current.organization`:

```ruby
# Good
Current.organization.projects

# Bad
Project.all
```

### Authentication & Authorization

**Authentication**: Devise

- Email/password authentication
- OAuth (Google, GitHub)
- User confirmations
- Password resets

**Authorization**: Pundit

- Policy-based authorization
- `pundit_user` returns `Current.membership` (not `current_user`)
- Policies check membership roles and organization access

### Core Domain Models

**Organization** → The tenant

- Has many users (through memberships)
- Has many projects
- Has subscriptions (via Pay gem)
- Has an owner (user)

**User** → Global user account

- Can belong to multiple organizations
- Has connected accounts (OAuth)
- Has referrals

**Membership** → Join table (User ↔ Organization)

- Has role: `member` or `admin`
- Validates uniqueness of user+organization
- Cannot remove last admin or owner

**Project** → Example resource

- Belongs to organization
- Scoped to organization
- Uses obfuscated IDs (Sqids)

## Development Commands

### Setup and Server

```bash
bin/setup              # Initial setup (installs gems, creates DB, loads schema)
bin/dev                # Start development server
```

### Testing

```bash
rails test             # Run all tests
rails test:system      # Run system tests
```

### Code Quality

```bash
bundle exec rubocop -A           # Ruby linting
bundle exec erb_lint --lint-all  # ERB linting
i18n-tasks normalize             # Sort i18n keys
```

### Database

```bash
rails db:migrate       # Run migrations
rails db:seed          # Seed database (creates Stripe products)
```

## Common Patterns

### Adding a New Organization-Scoped Resource

1. Generate nested scaffold:

   ```bash
   rails generate nested_scaffold organization/resource name:string
   ```

2. Add Pundit policy:

   ```bash
   rails g pundit:policy resource
   ```

3. Ensure resource belongs to organization:

   ```ruby
   class Resource < ApplicationRecord
     belongs_to :organization
   end
   ```

4. Scope queries in controller:
   ```ruby
   def index
     @resources = Current.organization.resources
   end
   ```

### Authorization Pattern

```ruby
class Organizations::ProjectsController < Organizations::BaseController
  def index
    authorize Project  # Checks Pundit policy
    @projects = @organization.projects
  end

  def create
    @project = @organization.projects.new(project_params)
    authorize @project  # Checks create permission
    # ...
  end
end
```

## Coding Style

- **Thin controllers, rich models**: Move business logic to models
- **Method ordering**: Order private methods by invocation order
- **Intention-revealing names**: Use `archive` not `update(status: :archived)`
- **Current context**: Always use `Current` for request-scoped data

## Common Tasks

### Adding Subscription Protection

```ruby
class Organizations::ProjectsController < Organizations::BaseController
  before_action :require_subscription

  # require_subscription is defined in Organizations::BaseController
end
```

## Important Notes

- **Always scope to organization**: Never query resources without organization scope
- **Use Current context**: Don't pass organization around manually
- **Pundit uses membership**: `pundit_user` returns `Current.membership`, not `current_user`
- **Obfuscated IDs**: Projects use Sqids for URL obfuscation (see `ObfuscatesId` concern)

## When Adding Features

1. Check if it should be organization-scoped
2. Use nested scaffold if it's a new resource
3. Add Pundit policy for authorization
4. Write tests
