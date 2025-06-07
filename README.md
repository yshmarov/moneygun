# Moneygun - Simple Rails 8 SaaS Boilerplate

A production-ready Ruby on Rails boilerplate for building multi-tenant SaaS applications. Built with best practices, modern tooling, and a focus on developer experience.

[![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-8.1.0-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

![Moneygun features](https://i.imgur.com/QUmTexS.png)

## 🚀 Features

### Core Functionality

- **Multi-tenant Architecture**: Route-based organization management
- **Authentication & Authorization**: Built with Devise and Pundit
- **Subscription Management**: Integrated Stripe payments via Pay gem
- **Team Management**: Organization creation, member invitations, and role management
- **Modern UI**: Clean, responsive design that you can easily extend
- **Dark mode & Themes**

> 💡 **Teams as MVP**: [Teams should be an MVP feature!](https://blog.bullettrain.co/teams-should-be-an-mvp-feature/) - Learn why implementing teams early is crucial for SaaS applications.

### Deployment

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/yshmarov/moneygun)

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/yshmarov/moneygun)

### Developer Experience

- **Complete Test Coverage**
- **Nested Resource Generation**: Fast development with nested scaffold generators

## 🎯 Why Moneygun?

### Route-Based Multi-tenancy

Unlike traditional approaches (subdomains, user.organization_id), Moneygun uses route-based multi-tenancy which offers several advantages:

- Support for multiple organizations in different browser tabs
- No complex subdomain configuration required

### 📚 Video Tutorials

1. **Row-level Route-based Multitenancy**
   Learn how to implement row-level route-based multitenancy in Ruby on Rails

   <a href="https://superails.com/posts/row-level-route-based-multitenancy">
     <img src="https://i3.ytimg.com/vi/KMonLTvWR5g/maxresdefault.jpg" title="Row-level route-based multitenancy in Ruby on Rails" width="50%" />
   </a>

2. **Multitenancy & Teams Boilerplate**
   Learn how to implement teams and multitenancy in your Rails application

   <a href="https://superails.com/posts/moneygun-teams-multitenancy-boilerplate">
     <img src="https://i.ytimg.com/vi/hzfl6h5SlH8/hqdefault.jpg" title="Moneygun - Multitenancy & Teams boilerplate" width="50%" />
   </a>

3. **Add ActsAsTenant to Existing Application**
   Step-by-step guide to adding ActsAsTenant to your existing Rails application

   <a href="https://superails.com/posts/moneygun-add-actsastenant-to-an-existing-application">
     <img src="https://i.ytimg.com/vi/YzvWRzNwdiM/hqdefault.jpg" title="Moneygun - Add ActsAsTenant to an existing application" width="50%" />
   </a>

4. **Build Your Next B2B SaaS**
   Enable Subscriptions with Stripe and launch your B2B SaaS application with Moneygun

   <a href="https://superails.com/posts/233-build-your-next-b2b-saas-with-moneygun-saas-multitenancy-boilerplate">
     <img src="https://i.ytimg.com/vi/KjlEm1kRYFY/hqdefault.jpg" title="Build your next B2B SaaS with Moneygun" width="50%" />
   </a>

### Resource Organization

Resources are organized in a logical hierarchy:

```ruby
/organizations/:id/projects/:id/tasks/:id
```

This structure provides:

- Clear resource ownership
- Intuitive navigation
- Easy access control
- Simplified querying

## 🛠️ Getting Started

1. Clone the repository:

```bash
git clone git@github.com:yshmarov/moneygun.git your_project_name
cd your_project_name
```

2. Set up the application:

```bash
bundle install
rails db:create db:migrate
```

3. Start the development server:

```bash
bin/dev
```

## 💳 Stripe Integration

Moneygun uses the [Pay](https://github.com/jumpstart-pro/pay) gem for handling Stripe subscriptions. Here's how to set it up:

### 1. Configure Stripe Credentials

Add your Stripe credentials to your Rails credentials:

```bash
rails credentials:edit
```

Add the following structure:

```yaml
stripe:
  publishable_key: sk_
  public_key: pk_
  webhook_receive_test_events: true
  signing_secret:
    - whsec_
```

### 2. Create Stripe Products and Prices

You can create the required Stripe products and prices in two ways:

1. **Automatically via seeds**:

   ```bash
   rails db:seed
   ```

   This will create a "Pro plan" product with monthly ($99) and yearly ($999) prices.

2. **Manually in Stripe Dashboard**:
   - Create a product named "Pro plan"
   - Add two prices:
     - Monthly: $99/month
     - Yearly: $999/year

### 3. Configure Plans

Add your Stripe price IDs to `config/settings.yml`:

```yaml
shared:
  plans:
    - id: price_xxx # Monthly price ID
      unit_amount: 9900
      currency: USD
      interval: month
    - id: price_yyy # Yearly price ID
      unit_amount: 99900
      currency: USD
      interval: year
```

### 4. Stripe webhooks

For development, Stripe webhook listener is already configured in `Procfile.dev`

```bash
stripe listen --forward-to localhost:3000/pay/webhooks/stripe
```

To enable webhooks:

- Development: [Click here](https://dashboard.stripe.com/test/webhooks/create?events=charge.succeeded%2Ccharge.refunded%2Cpayment_intent.succeeded%2Cinvoice.upcoming%2Cinvoice.payment_action_required%2Ccustomer.subscription.created%2Ccustomer.subscription.updated%2Ccustomer.subscription.deleted%2Ccustomer.subscription.trial_will_end%2Ccustomer.updated%2Ccustomer.deleted%2Cpayment_method.attached%2Cpayment_method.updated%2Cpayment_method.automatically_updated%2Cpayment_method.detached%2Caccount.updated%2Ccheckout.session.completed%2Ccheckout.session.async_payment_succeeded) to create a new Stripe webhook with all the events pre-filled.
- Production: [Click here](https://dashboard.stripe.com/webhooks/create?events=charge.succeeded%2Ccharge.refunded%2Cpayment_intent.succeeded%2Cinvoice.upcoming%2Cinvoice.payment_action_required%2Ccustomer.subscription.created%2Ccustomer.subscription.updated%2Ccustomer.subscription.deleted%2Ccustomer.subscription.trial_will_end%2Ccustomer.updated%2Ccustomer.deleted%2Cpayment_method.attached%2Cpayment_method.updated%2Cpayment_method.automatically_updated%2Cpayment_method.detached%2Caccount.updated%2Ccheckout.session.completed%2Ccheckout.session.async_payment_succeeded) to create a new Stripe webhook with all the events pre-filled.

Example production webhook url: `https://moneygun.com/pay/webhooks/stripe`

#### Require active subscription to access a resource

You can use the `require_subscription` before_action to protect routes:

```ruby
before_action :require_subscription

private

def require_subscription
  unless current_organization.payment_processor.subscribed?
    flash[:alert] = "You need to subscribe to access this page."
    redirect_to organization_subscriptions_url(current_organization)
  end
end
```

#### Subscription Status Indicators

Use the subscription status helper to show subscription state:

```ruby
subscription_status_label(organization)
# Returns:
# 🔴 - No subscription
# 🟠 - Subscription cancelled (on grace period)
# 🟢 - Active subscription
```

## 👷‍♂️ Development Guide

### Resource Generation

Generate nested resources quickly using the nested_scaffold gem:

```bash
rails generate nested_scaffold organization/project name
```

### Authorization

Generate Pundit policies for your resources:

```bash
rails g pundit:policy project
```

### Best Practices

#### Resource Associations

Always associate resources with `membership` instead of `user`:

```ruby
# ✅ Correct
class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :membership
end

# ❌ Avoid
class Project < ApplicationRecord
  belongs_to :user
end
```

#### Organization Scoping

Scope downstream models to organization for easier querying:

```ruby
class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project
end
```

## 🧪 Testing

Run the test suite:

```bash
rails test:all
```

### Code Quality

```bash
# ERB linting
bundle exec erb_lint --lint-all -a

# Ruby linting
bundle exec rubocop -A
```

```bash
# Alphabetically sort i18n keys
i18n-tasks normalize
```

# ✨ Contributors

<a href="https://avohq.io/contributors">
  <img src="https://contrib.rocks/image?repo=yshmarov/moneygun" />
</a>
<!--  https://contrib.rocks -->

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Design inspiration from Basecamp, Linear, Trello, Discord, and Slack
- [Bullet Train](https://bullettrain.co/) for SaaS patterns and inspiration (obfuscates_id, super scaffolding, teams architecture)
- [Jumpstart Pro](https://jumpstartrails.com/) & co for maintaining the magnificent gems [pay](http://github.com/pay-rails/pay), [acts_as_tenant](https://github.com/ErwinM/acts_as_tenant)
