# Moneygun

**The Rails 8 SaaS boilerplate for multi-tenant applications.**

[![Ruby on Rails](https://img.shields.io/badge/Rails-8-red.svg)](https://rubyonrails.org/)
[![CI](https://github.com/yshmarov/moneygun/actions/workflows/ci.yml/badge.svg)](https://github.com/yshmarov/moneygun/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENCE.md)
[![GitHub Stars](https://img.shields.io/github/stars/yshmarov/moneygun?style=social)](https://github.com/yshmarov/moneygun)

![Moneygun features](https://i.imgur.com/QUmTexS.png)

## Why Moneygun?

Skip weeks of boilerplate. Ship your B2B SaaS faster with production-ready:

- **Multi-tenant architecture** - Route-based organization management
- **Team management** - Invitations, roles, member administration
- **Stripe subscriptions** - Payments via Pay gem, ready to monetize
- **Authentication** - Devise + OAuth (Google, GitHub)
- **Authorization** - Pundit policies per organization
- **Modern UI** - Tailwind CSS, daisyUI, dark mode

> Teams should be an MVP feature. [Learn why](https://blog.bullettrain.co/teams-should-be-an-mvp-feature/)

## Quick Start

```bash
git clone git@github.com:yshmarov/moneygun.git my-saas
cd my-saas
bin/setup
bin/dev
```

## Deploy

Deploy to production with [Kamal](https://kamal-deploy.org/). See the [Deployment Guide](docs/deployment.md) for details.

## Documentation

| Guide | Description |
|-------|-------------|
| [Getting Started](docs/getting-started.md) | Installation and setup |
| [Architecture](docs/architecture.md) | Multi-tenancy, models, patterns |
| [Stripe Integration](docs/stripe-integration.md) | Payments and subscriptions |
| [Development](docs/development.md) | Testing, linting, conventions |
| [Deployment](docs/deployment.md) | Production deployment guides |
| [Linting](docs/linting.md) | Code quality tools |

## Video Tutorials

<table>
  <tr>
    <td width="50%">
      <a href="https://superails.com/posts/rails-7-115-multitenancy-teams-and-roles-without-a-gem">
        <img src="https://i3.ytimg.com/vi/KMonLTvWR5g/maxresdefault.jpg" alt="Route-based multitenancy" />
      </a>
      <br><strong>Route-based Multitenancy</strong>
    </td>
    <td width="50%">
      <a href="https://superails.com/posts/233-build-your-next-b2b-saas-with-moneygun-saas-multitenancy-boilerplate">
        <img src="https://i.ytimg.com/vi/KjlEm1kRYFY/hqdefault.jpg" alt="Build your B2B SaaS" />
      </a>
      <br><strong>Build Your B2B SaaS</strong>
    </td>
  </tr>
</table>

## How Does Moneygun Compare?

Moneygun is a lightweight starting point. [Bullet Train](https://bullettrain.co/) and [Jumpstart Pro](https://jumpstartrails.com/) are more full-featured frameworks with ongoing support.

| Feature | Moneygun | Bullet Train | Jumpstart Pro |
|---------|----------|--------------|---------------|
| **Price** | Free | Free | $249-749/yr |
| **License** | MIT | MIT | Commercial |
| **Multi-tenancy** | Route-based | Team-based | Multiple strategies |
| **Authentication** | Devise + OAuth | Devise + OAuth | Devise + OAuth |
| **Two-factor auth** | - | Yes | Yes |
| **Authorization** | Pundit | CanCanCan | Pundit |
| **Payments** | Stripe (Pay gem) | Stripe (Pay gem) | Stripe, Paddle, Lemon Squeezy, Braintree (Pay gem) |
| **Teams & Invitations** | Yes | Yes | Yes |
| **Admin panel** | Avo | Avo | Madmin |
| **REST API** | - | Yes (OpenAPI 3.1) | Yes |
| **Outgoing webhooks** | - | Yes | - |
| **Code generation** | Custom scaffold | Super Scaffolding | Rails scaffold |
| **Mobile apps (iOS/Android)** | Coming soon | - | Hotwire Native ($199-599/yr) |
| **Notifications** | Noticed | ActionMailer + ActionCable | Noticed |
| **Audit logs** | - | Yes | - |
| **User impersonation** | Yes (Masquerade) | - | Yes (Pretender) |
| **Feature flags** | Flipper | - | - |
| **I18n** | Partial (EN, FR) | Yes | Yes |
| **UI framework** | Tailwind + daisyUI | Tailwind (custom theme) | Tailwind + daisyUI |
| **Background jobs** | GoodJob | Sidekiq | SolidQueue / Sidekiq |
| **Official support** | Community | Yes | Yes |

**Choose Moneygun** if you want a free, simple foundation you fully own and understand — no framework abstractions, no subscription, just plain Rails you can read top to bottom.

**Choose [Bullet Train](https://bullettrain.co/)** if you need a production-grade framework with advanced features, code generation, official support, and a team behind it.

## Contributors

<a href="https://github.com/yshmarov/moneygun">
  <img src="https://contrib.rocks/image?repo=yshmarov/moneygun" />
</a>

## License

MIT License - see [LICENCE](LICENCE.md)

## Acknowledgments

Inspired by [Bullet Train](https://bullettrain.co/) and [Jumpstart Pro](https://jumpstartrails.com/).
