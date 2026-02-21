# Deployment

Moneygun deploys with [Kamal](https://kamal-deploy.org/) — zero-downtime Docker deployments to any server.

## Prerequisites

- A server (VPS) with SSH access (e.g. Hetzner, DigitalOcean, AWS EC2)
- A Docker Hub account (or other container registry)
- A domain name pointing to your server

## 1. Configure Kamal

Edit `config/deploy.yml`:

```yaml
service: moneygun
image: your-dockerhub-user/moneygun

servers:
  web:
    - YOUR_SERVER_IP
  job:
    hosts:
      - YOUR_SERVER_IP
    cmd: bundle exec good_job start

proxy:
  ssl: true
  host: yourdomain.com
  forward_headers: true

registry:
  username: your-dockerhub-user
  password:
    - KAMAL_REGISTRY_PASSWORD
```

## 2. Configure Secrets

Edit `.kamal/secrets` to reference your credentials:

```bash
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY=$(cat config/master.key)
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
DATABASE_URL="postgres://moneygun:${POSTGRES_PASSWORD}@moneygun-db:5432/moneygun_production"
```

Set the environment variables on your local machine:

```bash
export KAMAL_REGISTRY_PASSWORD=your-docker-hub-token
export POSTGRES_PASSWORD=your-secure-password
```

## 3. Set Up the Server

```bash
bin/kamal setup
```

This provisions the server with Docker, starts the PostgreSQL accessory, builds and pushes the image, and deploys the app.

## 4. Deploy

```bash
bin/kamal deploy
```

## Common Commands

```bash
# Rails console
bin/kamal console

# Shell access
bin/kamal shell

# Tail logs
bin/kamal logs

# Database console
bin/kamal dbc

# Run a one-off command
bin/kamal app exec "bin/rails db:migrate"

# Restart the app
bin/kamal app boot

# Check deployment details
bin/kamal details
```

## Database

PostgreSQL runs as a Kamal accessory on the same server (configured in `config/deploy.yml` under `accessories.db`). The `DATABASE_URL` is constructed in `.kamal/secrets` and injected into the app container.

To run migrations after deploy:

```bash
bin/kamal app exec "bin/rails db:migrate"
```

## SSL

Kamal's built-in proxy (kamal-proxy) handles SSL via Let's Encrypt automatically when `proxy.ssl: true` is set in `config/deploy.yml`.

If using Cloudflare, set the SSL/TLS encryption mode to **Full** to enable Cloudflare-to-app encryption.

## Production Checklist

Before deploying to production:

1. **Credentials**: Ensure `config/master.key` exists locally (never commit it)
2. **Database**: `POSTGRES_PASSWORD` env var set
3. **Registry**: `KAMAL_REGISTRY_PASSWORD` env var set
4. **Domain**: DNS A record pointing to your server IP
5. **Stripe**: Production API keys in `config/credentials/production.yml.enc`
6. **OAuth**: Production callback URLs registered with Google/GitHub
7. **Storage**: Object storage configured for Active Storage (S3, etc.) or use the local volume
8. **Email**: SMTP configured for transactional emails

## Stripe Webhook URL

Configure your production Stripe webhook:

```
https://yourdomain.com/pay/webhooks/stripe
```

See [Stripe Integration](stripe-integration.md) for webhook event configuration.
