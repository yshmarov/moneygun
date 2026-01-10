# Fly.io Deployment Guide

## Step-by-Step Deployment

### 1. Create App

```bash
fly launch
# Follow prompts to create app and generate fly.toml
```

Or create app manually:

```bash
fly apps create moneygun
```

### 2. Create and Attach Database

```bash
# Create PostgreSQL database
fly postgres create --name moneygun-db

# Attach database to app (sets DATABASE_URL automatically)
fly postgres attach --app moneygun moneygun-db
```

### 3. Set App Credentials

```bash
# Set Rails master key
fly secrets set RAILS_MASTER_KEY=$(cat config/credentials/production.key) --app moneygun
```

### 4. Create Tigris (AWS proxy) Storage

```bash
# Create storage bucket (sets AWS_* and BUCKET_NAME automatically)
fly storage create --app moneygun
```

### 5. Deploy App

```bash
fly deploy --app moneygun
```

### 6. Run Database Migrations

Migrations run automatically via `release_command` in `fly.toml`. To run manually:

```bash
fly ssh console --app moneygun
bin/rails db:migrate
```

## App Console

```bash
# SSH into app
fly ssh console --app moneygun

# Run Rails console
bin/rails console

# Run a rake task remotely (without SSH session)
fly ssh console --app moneygun -C "/rails/bin/rails users:confirm_all"
```

## Health Checks

```bash
# Check app status
fly status --app moneygun

# View logs
fly logs --app moneygun

# Check health endpoint
curl https://moneygun.fly.dev/up
```

## Troubleshooting

```bash
# Check secrets (names only, not values)
fly secrets list --app moneygun

# Read value of a specific env var (SSH into machine)
fly ssh console --app moneygun
echo $RAILS_MASTER_KEY

# Restart app
fly apps restart moneygun
```
