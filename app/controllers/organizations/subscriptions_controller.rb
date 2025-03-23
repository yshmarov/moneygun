class Organizations::SubscriptionsController < Organizations::BaseController
  before_action :require_billing_enabled
  before_action :require_current_organization_admin

  def index
    @organization.set_payment_processor :stripe
    # @organization.payment_processor.sync_subscriptions(status: "all")
  end

  def checkout
    @organization.set_payment_processor :stripe
    @organization.payment_processor.sync_subscriptions(status: "all")
    return redirect_to organization_subscriptions_url(@organization) if @organization.payment_processor&.subscribed?

    price = Stripe::Price.retrieve(params[:price_id])
    return redirect_to organization_subscriptions_url(@organization) if price.nil?

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

  private

  def require_billing_enabled
    redirect_to organization_url(@organization) unless Rails.application.credentials.dig(:stripe, :private_key).present?
  end

  def require_current_organization_admin
    redirect_to organization_url(@organization) unless @current_membership.admin?
  end
end
