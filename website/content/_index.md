---
title: 'Moneygun — a production-minded Rails SaaS foundation'
description: 'Start with the Rails SaaS backbone that usually takes months to assemble: organizations, secure authentication, billing, enterprise identity, operations, and deployment.'
eyebrow: 'Open-source Rails SaaS foundation'
hero_title: 'Ship the product, not the boilerplate.'
hero_description: 'Moneygun gives a new Rails application the boring, consequential parts of SaaS from day one—without hiding Rails behind another framework.'
primary_cta: 'Explore the application'
secondary_cta: 'View on GitHub'
proof:
  - value: 'Rails 8'
    label: 'Plain Rails architecture'
  - value: 'Multi-tenant'
    label: 'Organization-scoped by default'
  - value: 'MIT'
    label: 'Use it without a platform tax'
features_intro: 'A coherent backbone, not a bag of generators.'
features:
  - title: 'Accounts and organizations'
    description: 'Passwordless sign-in, MFA, step-up authentication, invitations, roles, ownership transfer, onboarding, and safe account lifecycle.'
  - title: 'Tenant-safe application patterns'
    description: 'Route-based organizations, membership-scoped authorization, same-organization validation, public ID obfuscation, and audit history.'
  - title: 'Billing and enterprise identity'
    description: 'Stripe subscriptions through Pay, complimentary access, SAML SSO, verified domains, and SCIM provisioning.'
  - title: 'Secure file handling'
    description: 'Authenticated Active Storage delivery, safe image analysis, metadata sanitization hooks, and queued ClamAV scanning.'
  - title: 'Production operations'
    description: 'GoodJob, PgHero, AppSignal, health checks, backups, restore drills, smoke tests, and Kamal deployment.'
  - title: 'A UI you can keep'
    description: 'Hotwire, ViewComponent, Tailwind CSS, daisyUI, accessible interaction patterns, dark mode, and responsive navigation.'
principles:
  - title: 'Understand every layer'
    description: 'Moneygun stays close to Rails conventions. The application is yours to read, change, and operate.'
  - title: 'Start secure'
    description: 'Tenant boundaries, consequential actions, file delivery, audit evidence, and abuse controls are application primitives—not a later cleanup.'
  - title: 'Keep the product yours'
    description: 'The example module is intentionally replaceable. Moneygun supplies the SaaS backbone and stays out of your business domain.'
quick_start: |-
  git clone git@github.com:yshmarov/moneygun.git my-saas
  cd my-saas
  bin/setup
  bin/dev
closing_title: 'Start from a Rails application already shaped for production.'
closing_description: 'Clone Moneygun, replace the example module, and spend the next iteration on the reason your product should exist.'
---
