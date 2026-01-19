# Deployment

## Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/yshmarov/moneygun)

Click the button above for one-click deployment to Render.

## Heroku

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/yshmarov/moneygun)

Click the button above for one-click deployment to Heroku.

## Fly.io

### 1. Create App

```bash
fly launch
```

Or manually:

```bash
fly apps create your-app-name
```

### 2. Create Database

```bash
fly postgres create --name your-app-db
fly postgres attach --app your-app-name your-app-db
```

### 3. Set Credentials

```bash
fly secrets set RAILS_MASTER_KEY=$(cat config/credentials/production.key) --app your-app-name
```

### 4. Create Storage (Tigris)

```bash
fly storage create --app your-app-name
```

### 5. Deploy

```bash
fly deploy --app your-app-name
```

Migrations run automatically via `release_command` in `fly.toml`.

### Console Access

```bash
# SSH into app
fly ssh console --app your-app-name

# Rails console
bin/rails console

# Run rake task remotely
fly ssh console --app your-app-name -C "/rails/bin/rails users:confirm_all"
```

### Monitoring

```bash
fly status --app your-app-name    # App status
fly logs --app your-app-name      # View logs
curl https://your-app.fly.dev/up  # Health check
```

### Troubleshooting

```bash
fly secrets list --app your-app-name   # List secrets
fly apps restart your-app-name         # Restart app
```

## Production Checklist

Before deploying to production:

1. **Credentials**: Set `RAILS_MASTER_KEY` and ensure `config/credentials/production.yml.enc` exists
2. **Database**: PostgreSQL configured and accessible
3. **Stripe**: Production API keys and webhook endpoint configured
4. **OAuth**: Production callback URLs registered with Google/GitHub
5. **Storage**: Object storage configured for Active Storage (S3, Tigris, etc.)
6. **Email**: SMTP configured for transactional emails

## Stripe Webhook URL

Configure your production Stripe webhook:

```
https://yourdomain.com/pay/webhooks/stripe
```

See [Stripe Integration](stripe-integration.md) for webhook event configuration.
