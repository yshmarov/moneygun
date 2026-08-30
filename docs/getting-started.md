# Getting Started

## Prerequisites

- Ruby 4.0
- PostgreSQL
- Node.js 20+
- Stripe CLI (for webhook testing)

## Installation

### 1. Clone the Repository

```bash
git clone git@github.com:yshmarov/moneygun.git your_project_name
cd your_project_name

# Set up your own remote
git remote rename origin moneygun
git remote add origin https://github.com/your-account/your-repo.git
git push -u origin main
```

### 2. Run Setup

```bash
bin/setup
```

This installs dependencies, creates the database, and loads the schema.

### 3. Configure Credentials

```bash
rails credentials:edit
```

Add your API keys:

```yaml
stripe:
  publishable_key: pk_test_...
  secret_key: sk_test_...
  signing_secret:
    - whsec_...
```

For environment-specific credentials:

```bash
EDITOR="code --wait" rails credentials:edit --environment=development
```

### 4. Start Development Server

```bash
bin/dev
```

This starts:

- Rails server
- CSS build watcher
- Stripe webhook listener
- Background job processor

Visit http://localhost:3000

Authentication requires working email delivery in production. Development shows generated codes in the response UI. Active Record encryption derives its keys from `SECRET_KEY_BASE`, so that secret must be stable across deployments.

## Database

```bash
# Run migrations
rails db:migrate

# Seed sample data (creates Stripe products)
rails db:seed

# Reset database
rails db:reset
```

## Next Steps

- [Stripe Integration](stripe-integration.md) - Set up payments
- [Architecture](architecture.md) - Understand the codebase
- [Authentication](authentication.md) - Configure passwordless auth and MFA
- [Enterprise identity](enterprise-identity.md) - Configure SAML and SCIM
- [Development](development.md) - Testing and linting
- [Deployment](deployment.md) - Deploy to production
