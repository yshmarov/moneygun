# Moneygun

**A production-minded Rails 8 foundation for multi-tenant SaaS applications.**

[![Ruby on Rails](https://img.shields.io/badge/Rails-8-red.svg)](https://rubyonrails.org/)
[![CI](https://github.com/yshmarov/moneygun/actions/workflows/ci.yml/badge.svg)](https://github.com/yshmarov/moneygun/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENCE.md)

Moneygun is deliberately plain Rails: route-based organizations, membership-scoped authorization, and reusable infrastructure without a framework layered over the application.

## Included

- Route-based multi-tenancy with active/deactivated memberships, viewer access, and owner/admin invariants
- Passwordless email-code authentication, database-backed sessions, TOTP, backup codes, and step-up authentication
- Terms/profile onboarding, consent timestamps, banning, safe account closure/redaction, and expiring organization data exports
- Email-first organization invitations with expiry, resend throttling, acceptance, decline, revoke, and former-member reactivation
- Stripe subscriptions through Pay
- Pundit authorization with tenant-safe scopes
- Append-only, tenant-scoped audit logs with actor and request snapshots
- Authenticated Active Storage delivery, server-upload metadata stripping, decompression-bomb checks, and ClamAV scanning
- Background image-variant preprocessing, cacheable external SVG icons, and enforced browser security policies
- Per-organization SAML 2.0 SSO with verified domains, enforcement, JIT, signed assertions, and replay protection
- SCIM 2.0 provisioning with one-time bearer tokens and safe member lifecycle rules
- Tailwind CSS 4, daisyUI 5, Hotwire, ViewComponent, shared page/shell components, and dark mode
- Avo, GoodJob, PgHero, Flipper, Noticed, AppSignal, accessibility checks, and production-oriented lint/security checks
- Kamal deployment, database backups with restore drills, image/configuration scanning, and conservative registry pruning
- A standalone Hugo one-page website for the main domain, with the Rails application conventionally hosted at `app.<domain>`
- `Project`, an example mini-app demonstrating tenant ownership, rich forms, files, policies, and audit events

Moneygun contains no product-specific business domain. The example module is intended to be replaced.

## Quick start

Prerequisites are Ruby 4.0, PostgreSQL, Node.js, Hugo, and the Stripe CLI when developing billing.

```bash
git clone git@github.com:yshmarov/moneygun.git my-saas
cd my-saas
bin/setup
bin/dev
```

Open the website at [http://localhost:4000](http://localhost:4000) and the Rails application at [http://localhost:3000](http://localhost:3000). In development, email verification codes are shown in the UI as well as delivered through the configured mailer.

## Verify a change

```bash
bin/ci
```

`bin/ci` prepares the app, runs formatting, lint, security and dependency audits, checks eager loading and database health, then runs unit, system, and seed tests. Use `bin/lint --fix` for safe formatting and lint autocorrections.

## Documentation

| Guide                                              | Purpose                                             |
| -------------------------------------------------- | --------------------------------------------------- |
| [Getting started](docs/getting-started.md)         | Local installation and application configuration    |
| [Architecture](docs/architecture.md)               | Tenancy, current context, models, and authorization |
| [Authentication](docs/authentication.md)           | Passwordless sessions, MFA, sudo, and email changes |
| [Security](docs/security.md)                       | Tenant isolation, audit logs, and file delivery     |
| [Enterprise identity](docs/enterprise-identity.md) | SAML and SCIM configuration and guarantees          |
| [Mini-app pattern](docs/mini-app-pattern.md)       | Building or replacing an organization module        |
| [Stripe integration](docs/stripe-integration.md)   | Plans, webhooks, and paywalls                       |
| [Development](docs/development.md)                 | Tests, linting, and conventions                     |
| [Linting and audits](docs/linting.md)              | Local quality gate and automated dependency checks  |
| [Deployment](docs/deployment.md)                   | Production deployment with Kamal                    |
| [Website](website/README.md)                       | Main-domain Hugo site and app-subdomain convention  |

## Design choices

- A user may belong to several organizations; tenant state lives in `Membership`, not `User`.
- Organization resources carry both `organization` and `membership`, with a same-organization invariant.
- Signed file URLs do not bypass authorization.
- SSO/SCIM identity providers cannot silently adopt an existing global account into a new tenant.
- Audit events are append-only, but disappear with their organization to preserve tenant deletion semantics.
- Sensitive changes require recent proof of control, independent of the long-lived session.

## Deployment

Moneygun includes Kamal configuration. See the [deployment guide](docs/deployment.md). Configure production mail delivery, Stripe credentials, storage, and a stable `SECRET_KEY_BASE` before enabling authentication or encrypted MFA data.

## License

MIT License. See [LICENCE.md](LICENCE.md).
