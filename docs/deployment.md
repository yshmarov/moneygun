# Deployment

Moneygun ships two deliberately separate deployment surfaces:

- The Hugo website serves the apex domain, such as `https://example.com`.
- The Rails application serves an application subdomain, such as `https://app.example.com`.

The Rails baseline uses [Kamal](https://kamal-deploy.org/): separate web and GoodJob roles, PostgreSQL with PgHero history, S3-compatible object storage, ClamAV upload scanning, container health checks, bounded shutdowns, registry build caching, and log rotation. The website includes an opt-in Cloudflare Pages workflow.

The checked-in values are examples. Configure them before the first deploy.

## Prerequisites

- An amd64 server reachable over SSH
- An apex domain for the website and an application subdomain whose DNS points to the Rails server
- A container registry account
- An S3-compatible bucket
- Production email delivery and application credentials
- An AppSignal application and Push API key when production monitoring is enabled

## Configuration

`config/deploy.yml` accepts these environment variables:

| Variable                  | Purpose                                               | Example                          |
| ------------------------- | ----------------------------------------------------- | -------------------------------- |
| `KAMAL_HOST`              | Server address                                        | `203.0.113.10`                   |
| `APP_HOST`                | Public application host                               | `app.example.com`                |
| `KAMAL_IMAGE`             | Registry namespace and image                          | `acme/moneygun`                  |
| `KAMAL_REGISTRY_SERVER`   | Registry host                                         | `ghcr.io`                        |
| `KAMAL_REGISTRY_USERNAME` | Registry username                                     | `acme`                           |
| `AWS_REGION`              | Object-storage region                                 | `auto` or `eu-west-1`            |
| `AWS_ENDPOINT_URL_S3`     | S3-compatible endpoint; omit for AWS when appropriate | `https://fly.storage.tigris.dev` |
| `BUCKET_NAME`             | Active Storage bucket                                 | `acme-production`                |
| `BACKUP_IMAGE`            | PostgreSQL 18 backup image                            | `acme/postgres-backup-s3:18`     |
| `BACKUP_SCHEDULE`         | Database backup cron in UTC                           | `0 3 * * *`                      |
| `BACKUP_KEEP_DAYS`        | Dumps retained by the backup container                | `21`                             |
| `BACKUP_BUCKET_NAME`      | Backup bucket; defaults to `BUCKET_NAME`              | `acme-backups`                   |
| `BACKUP_S3_PREFIX`        | Backup object prefix                                  | `backups/postgres`               |
| `BACKUP_S3_ENDPOINT`      | Backup endpoint; defaults to Active Storage endpoint  | `https://s3.example.com`         |

The following values are secrets and are read by `.kamal/secrets`:

```bash
export KAMAL_REGISTRY_PASSWORD=...
export RAILS_MASTER_KEY=...
export POSTGRES_PASSWORD=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

When `RAILS_MASTER_KEY` is not exported, local deploys fall back to `config/master.key`. Never commit that file. Keep the master key and database password in a password manager; losing either can make production data unrecoverable.

AppSignal reads `appsignal` from Rails credentials. `APPSIGNAL_PUSH_API_KEY` can override it in environments where credentials are not used, and `APPSIGNAL_ACTIVE=false` disables reporting for production-mode diagnostics.

Production boot validates `HOST` and `DATABASE_URL`, plus the S3 credentials and bucket when `ACTIVE_STORAGE_SERVICE=s3`. A missing value stops the process immediately instead of surfacing as a delayed runtime error.

## First deploy

Run the complete local gate, then provision the host:

```bash
bin/ci
bin/kamal config
bin/kamal setup
```

`kamal setup` installs Docker, starts the PostgreSQL accessory, builds the image, prepares the database through `bin/docker-entrypoint`, and boots the web and worker roles. Subsequent releases use:

```bash
bin/ci
bin/kamal deploy
```

The web role never runs cron. The GoodJob role owns scheduled work and exposes a database-connected health endpoint on port 7001, so a worker that cannot reach PostgreSQL is not considered healthy.

The worker also owns the persistent `clamav_signatures` volume. It seeds missing virus definitions at boot and refreshes them daily. File-serving controllers fail closed while a protected upload is pending or failed; keep the dedicated `virus_scan` queue and do not remove the signature volume without replacing that scanner contract. PgHero query collection depends on the PostgreSQL accessory's `shared_preload_libraries=pg_stat_statements` command.

## GitHub deployment

`.github/workflows/deploy.yml` can deploy manually from Actions. Automatic deployment is deliberately opt-in: set the repository variable `KAMAL_DEPLOY_ENABLED` to `true`. Once enabled, a successful `CI` run for a push to `main` starts deployment; failed or draft CI never does.

Create a `production` environment and configure:

Repository or environment secrets:

- `KAMAL_HOST`
- `SSH_PRIVATE_KEY`
- `SSH_KNOWN_HOSTS`
- `KAMAL_REGISTRY_PASSWORD`
- `RAILS_MASTER_KEY`
- `POSTGRES_PASSWORD`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Repository or environment variables:

- `APP_HOST`
- `KAMAL_IMAGE`
- `KAMAL_REGISTRY_USERNAME`
- `KAMAL_REGISTRY_SERVER` (defaults to `ghcr.io`)
- `AWS_REGION` (defaults to `auto`)
- `AWS_ENDPOINT_URL_S3` (optional)
- `BUCKET_NAME`
- `BACKUP_BUCKET_NAME` (optional; defaults to `BUCKET_NAME`)
- `APPSIGNAL_APP_NAME` (optional; defaults to `Moneygun`)

Optional workflow secrets:

- `APPSIGNAL_PUSH_API_KEY` records a release marker after a successful Kamal deploy.
- `DEPLOY_FAILURE_WEBHOOK_URL` receives a small JSON notification when deployment fails.
- `GHCR_PRUNE_TOKEN` is required only when registry pruning is enabled; use a narrowly scoped package token owned by the same account as the package.

Store the exact host key in `SSH_KNOWN_HOSTS`; do not replace host verification with `StrictHostKeyChecking=no`. The workflow refuses an outdated revision when a newer commit has reached `main`.

### Website deployment

Customize `website/hugo.yaml` first. The production values must describe the same split as Rails: the Hugo `baseURL` is the apex website and `params.app_url` points to the Rails subdomain.

`.github/workflows/deploy-website.yml` publishes `website/public` to Cloudflare Pages when files under `website/` reach `main`. It is opt-in; configure the following before setting `WEBSITE_DEPLOY_ENABLED=true`:

Secrets:

- `CLOUDFLARE_API_TOKEN` with access only to the intended Pages project
- `CLOUDFLARE_ACCOUNT_ID`

Variables:

- `WEBSITE_URL`, for example `https://example.com`
- `CLOUDFLARE_PAGES_PROJECT`

Attach the apex domain to that Pages project and configure DNS in Cloudflare. The workflow injects `WEBSITE_URL` as Hugo's `baseURL`; the application origin remains the checked-in `params.app_url`. It then deploys and checks `/`, `/robots.txt`, and `/sitemap.xml`. Website-only commits do not start a Kamal deployment.

## Operations

```bash
bin/kamal details
bin/kamal logs
bin/kamal logs -r job
bin/kamal console
bin/kamal shell
bin/kamal dbc
bin/kamal accessory logs db
```

The admin gate exposes GoodJob at `/jobs`, PgHero at `/pghero`, feature flags at `/feature_flags`, and Allgood at `/healthcheck`. After deployment, run the non-mutating HTTP smoke test:

```bash
bin/smoke https://app.example.com
```

The container entrypoint runs `db:prepare` before the web process starts, so normal deployments do not need a separate migration command.

## Backups and recovery

The `db_backup` accessory creates nightly PostgreSQL custom-format dumps in S3-compatible object storage and retains 21 days by default. The PostgreSQL accessory volume and object-storage bucket remain persistent, but persistence alone is not a backup.

Moneygun also codifies an independent bucket lifecycle in `config/backup_lifecycle.json`. It expires current database dumps after 21 days, noncurrent backup versions after another 7 days, other noncurrent versions after 30 days, and abandoned multipart uploads after 7 days. Review those defaults for your provider and compliance requirements, then explicitly apply them:

```bash
bin/backup-lifecycle check
bin/backup-lifecycle apply
```

`apply` refuses to erase lifecycle rules that are not represented in the checked-in configuration and verifies the provider's read-back after changing it.

Run a restore drill with:

```bash
bin/backup-restore-test
bin/backup-restore-test optional-specific-dump.dump
```

The drill downloads a dump through the backup container, restores it into an isolated PostgreSQL 18 container and volume on the application host, compares its table set and row counts with the live database, and cleans up the scratch resources. It never writes to production. Set `BACKUP_RESTORE_ENABLED=true` to enable the monthly GitHub workflow; it checks lifecycle drift before restoring the latest dump.

Object-storage versioning, encryption, and access boundaries are provider responsibilities. Verify them separately before treating the deployment as production-ready.

## Maintenance workflows

- `infrastructure-scan.yml` builds the production image monthly and fails on fixed high or critical image/configuration findings.
- `prune-registry.yml` is disabled until `GHCR_PRUNE_ENABLED=true`. Scheduled runs preserve the newest 20 tagged application releases and all child manifests they reference. Manual runs default to dry-run. Configure `GHCR_PACKAGE_NAME` and `GHCR_CACHE_PACKAGE_NAME` when package names differ from repository defaults.
- `dependabot-auto-merge.yml` enables auto-merge only for eligible Dependabot patch and minor updates after required checks succeed.

These workflows are operational controls, not substitutes for watching AppSignal, GitHub Actions, backup age, disk consumption, and the actual provider dashboards.

## Production checklist

1. `bin/ci` passes on the exact revision being deployed.
2. Apex DNS and the website deployment's `WEBSITE_URL` agree; application-subdomain DNS and `APP_HOST` agree.
3. Registry, SSH, Rails, PostgreSQL, and object-storage secrets are present.
4. Production email delivery is working; passwordless authentication depends on it.
5. Stripe live keys and the `https://APP_HOST/pay/webhooks/stripe` endpoint are configured if billing is enabled.
6. Object storage permits the application credentials to read, write, and delete only the intended bucket.
7. Database and object-storage restore drills have succeeded, and `bin/backup-lifecycle check` reports no drift.
8. `website/bin/smoke https://example.com`, `bin/smoke https://app.example.com`, the web role, the job role, ClamAV freshness, and a real email sign-in are healthy after deployment.
9. AppSignal has received a deploy and a test error from the production environment.
