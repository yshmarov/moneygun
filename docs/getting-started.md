# Getting Started

## Prerequisites

- Ruby 3.3+
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

google:
  client_id: ...
  client_secret: ...

github:
  client_id: ...
  client_secret: ...
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

## OAuth Setup

### Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials
3. Add authorized redirect URI:
   - Development: `http://localhost:3000/auth/google_oauth2/callback`
   - Production: `https://yourdomain.com/auth/google_oauth2/callback`

### GitHub OAuth

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Create a new OAuth App
3. Add callback URL:
   - Development: `http://localhost:3000/auth/github/callback`
   - Production: `https://yourdomain.com/auth/github/callback`

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
- [Development](development.md) - Testing and linting
- [Deployment](deployment.md) - Deploy to production
