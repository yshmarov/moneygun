# Moneygun

**The Rails 8 SaaS boilerplate for multi-tenant applications.**

[![Ruby on Rails](https://img.shields.io/badge/Rails-8-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

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

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/yshmarov/moneygun)
[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/yshmarov/moneygun)

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

## Contributors

<a href="https://github.com/yshmarov/moneygun">
  <img src="https://contrib.rocks/image?repo=yshmarov/moneygun" />
</a>

## License

MIT License - see [LICENSE](LICENSE)

## Acknowledgments

Inspired by [Bullet Train](https://bullettrain.co/) and [Jumpstart Pro](https://jumpstartrails.com/).
