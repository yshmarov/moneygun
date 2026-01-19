# Stripe Integration

Moneygun uses the [Pay](https://github.com/pay-rails/pay) gem for Stripe subscriptions.

## Configuration

### 1. Add Credentials

```bash
rails credentials:edit
```

```yaml
stripe:
  publishable_key: pk_test_...
  secret_key: sk_test_...
  webhook_receive_test_events: true
  signing_secret:
    - whsec_...
```

### 2. Create Products and Prices

**Option A: Via seeds**

```bash
rails db:seed
```

Creates a "Pro plan" with monthly ($99) and yearly ($999) prices.

**Option B: Manually in Stripe Dashboard**

1. Create a product named "Pro plan"
2. Add prices:
   - Monthly: $99/month
   - Yearly: $999/year

### 3. Configure Plans

Add Stripe price IDs to `config/settings.yml`:

```yaml
shared:
  plans:
    - id: price_xxx  # Monthly price ID
      unit_amount: 9900
      currency: USD
      interval: month
    - id: price_yyy  # Yearly price ID
      unit_amount: 99900
      currency: USD
      interval: year
```

## Webhooks

### Development

Stripe webhook listener is configured in `Procfile.dev` and starts automatically with `bin/dev`:

```bash
stripe listen --forward-to localhost:3000/pay/webhooks/stripe
```

### Production

Create a webhook endpoint in Stripe Dashboard:

- URL: `https://yourdomain.com/pay/webhooks/stripe`
- Events to subscribe:
  - `charge.succeeded`
  - `charge.refunded`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `checkout.session.completed`

Quick setup links with pre-filled events:
- [Development webhook](https://dashboard.stripe.com/test/webhooks/create?events=charge.succeeded%2Ccharge.refunded%2Cpayment_intent.succeeded%2Cinvoice.upcoming%2Cinvoice.payment_action_required%2Ccustomer.subscription.created%2Ccustomer.subscription.updated%2Ccustomer.subscription.deleted%2Ccustomer.subscription.trial_will_end%2Ccustomer.updated%2Ccustomer.deleted%2Cpayment_method.attached%2Cpayment_method.updated%2Cpayment_method.automatically_updated%2Cpayment_method.detached%2Caccount.updated%2Ccheckout.session.completed%2Ccheckout.session.async_payment_succeeded)
- [Production webhook](https://dashboard.stripe.com/webhooks/create?events=charge.succeeded%2Ccharge.refunded%2Cpayment_intent.succeeded%2Cinvoice.upcoming%2Cinvoice.payment_action_required%2Ccustomer.subscription.created%2Ccustomer.subscription.updated%2Ccustomer.subscription.deleted%2Ccustomer.subscription.trial_will_end%2Ccustomer.updated%2Ccustomer.deleted%2Cpayment_method.attached%2Cpayment_method.updated%2Cpayment_method.automatically_updated%2Cpayment_method.detached%2Caccount.updated%2Ccheckout.session.completed%2Ccheckout.session.async_payment_succeeded)

## Requiring Subscriptions

Protect routes that require an active subscription:

```ruby
class Organizations::ProjectsController < Organizations::BaseController
  before_action :require_subscription

  # ...
end
```

The `require_subscription` method is defined in `Organizations::BaseController`:

```ruby
def require_subscription
  unless Current.organization.has_access?
    flash[:alert] = "You need to subscribe to access this page."
    redirect_to organization_subscriptions_url(Current.organization)
  end
end
```

## Subscription Status

Display subscription state with the helper:

```ruby
subscription_status_label(organization)
```

Returns:
- Red indicator - No subscription
- Orange indicator - Subscription cancelled (on grace period)
- Green indicator - Active subscription
