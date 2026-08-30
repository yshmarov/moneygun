# Architecture

## Multi-Tenancy

Moneygun uses **route-based multi-tenancy** where resources are scoped under organizations:

```
/organizations/:organization_id/projects/:id
/organizations/:organization_id/memberships/:id
```

**Why route-based?** Unlike subdomain-based or `user.organization_id` approaches:

- Users can have multiple organizations open in different browser tabs
- No DNS/subdomain configuration required
- Clear resource ownership in URLs

## Current Context

The `Current` class provides request-scoped context throughout the application:

```ruby
Current.organization   # Current organization being accessed
Current.membership     # Current user's membership in the organization
Current.user           # Current authenticated user (via membership)
Current.organizations  # All organizations the user belongs to
```

**Always scope queries to the organization:**

```ruby
# Correct
Current.organization.projects

# Incorrect - exposes data across tenants
Project.all
```

## Core Models

### Organization

The tenant. Has many users through memberships.

- Has subscriptions (via Pay gem)
- Has an owner (user)
- Includes concerns: `Billing`, `Multitenancy`, `Transfer`, `Logo`, `Community`

### User

Global passwordless user account authenticated through email codes, optional TOTP, and database-backed sessions.

- Can belong to multiple organizations
- Can use organization SAML SSO where configured

### Membership

Join table connecting User and Organization.

- Has role: `member` or `admin`
- Validates uniqueness of user + organization
- Cannot remove last admin or owner
- Retains deactivated members so ownership and audit history remain resolvable

### Project

Example organization-scoped resource demonstrating the pattern.

- Belongs to organization
- Belongs to membership (creator)
- Uses obfuscated IDs via Sqids (`ObfuscatesId` concern)

## Controller Inheritance

Organization-scoped controllers inherit from `Organizations::BaseController`:

```ruby
class Organizations::ProjectsController < Organizations::BaseController
  def index
    authorize Project
    @projects = @organization.projects
  end
end
```

`Organizations::BaseController` provides:

- Sets `@organization` from `current_user.organizations`
- Sets `Current.membership` and `Current.organization`
- `require_subscription` for paywalled features

## Authorization

Uses Pundit with membership-based policies:

```ruby
# In ApplicationController
def pundit_user
  Current.membership
end
```

Policies receive `Current.membership` as the user context, enabling role-based access control per organization.

Generate policies:

```bash
rails g pundit:policy resource_name
```

## Routes Structure

Routes are split into separate files in `config/routes/`:

- `users.rb` - User account routes
- `organizations.rb` - Organization-scoped resources
- `admin.rb` - Admin panel routes
- `sso.rb` - SAML discovery and callback routes
- `scim.rb` - Token-authenticated SCIM endpoints

## Resource Association Pattern

Associate organization-scoped resources with `membership` (not `user`):

```ruby
class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :membership  # Creator
end
```

This ties the resource to both the organization and the specific membership that created it.

## Cross-cutting infrastructure

- `AuditLog` records organization, membership, authentication, and mini-app events.
- Active Storage controllers authorize the attached record on every download.
- `SsoConnection` and `ScimConnection` are owned by exactly one organization.

See [Authentication](authentication.md), [Security](security.md), and [Enterprise identity](enterprise-identity.md).

## Admin Panel

Avo admin panel at `/avo`. Resources defined in `app/avo/resources/`.

## Frontend Stack

- **Tailwind CSS 4** with **daisyUI 5** components
- **Hotwire** (Turbo + Stimulus) for interactivity
- **ViewComponent** for reusable UI components
