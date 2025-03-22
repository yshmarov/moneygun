class Organizations::SubscriptionsController < Organizations::BaseController
  PLANS = [
    {
      id: "price_1R5YtwLRcgxgTmfQgItFN1b0",
      unit_amount: 99900,
      currency: "PLN",
      interval: "month"
    },
    {
      id: "price_1R5YuELRcgxgTmfQyxBxCAlr",
      unit_amount: 99900,
      currency: "PLN",
      interval: "year"
    }
  ]

  def index
  end

  def checkout
    @organization.set_payment_processor :stripe
    @organization.payment_processor.sync_subscriptions(status: "all") unless Rails.env.test?
    return redirect_to organization_subscriptions_url(@organization) if @organization.payment_processor&.subscription&.active?

    price = Stripe::Price.retrieve(params[:price_id])

    @checkout_session = @organization.payment_processor.checkout(
      mode: "subscription",
      locale: I18n.locale,
      line_items: [ {
        price:,
        quantity: 1
      } ],
      allow_promotion_codes: true,
      automatic_tax: { enabled: true },
      tax_id_collection: { enabled: true },
      # consent_collection: { terms_of_service: :required },
      customer_update: { address: :auto, name: :auto },
      success_url: organization_subscriptions_url(@organization),
      cancel_url: organization_subscriptions_url(@organization)
    )

    redirect_to @checkout_session.url, allow_other_host: true, status: :see_other
  end

  def billing_portal
    @portal_session = @organization.payment_processor.billing_portal(
      return_url: organization_subscriptions_url(@organization)
    )
    redirect_to @portal_session.url, allow_other_host: true, status: :see_other
  end
end
