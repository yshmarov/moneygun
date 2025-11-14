# frozen_string_literal: true

class Organizations::SubscriptionsController < Organizations::BaseController
  before_action :require_billing_enabled
  before_action :require_current_organization_admin
  before_action :sync_subscriptions, only: %i[checkout success]
  before_action :sync_charges, only: %i[success]

  def index; end

  def checkout
    price = Stripe::Price.retrieve(params[:price_id])
    return redirect_to organization_subscriptions_url(@organization) if price.nil?

    # Determine if this is a one-time payment or subscription
    is_one_time = price.recurring.nil?

    # For subscriptions, check if already subscribed
    return redirect_to organization_subscriptions_url(@organization) if !is_one_time && @organization.payment_processor&.subscribed?

    @checkout_session = @organization.payment_processor.checkout(
      mode: is_one_time ? "payment" : "subscription",
      locale: I18n.locale,
      line_items: [{
        price:,
        quantity: 1
      }],
      allow_promotion_codes: true,
      automatic_tax: { enabled: true },
      tax_id_collection: { enabled: true },
      # consent_collection: { terms_of_service: :required },
      customer_update: { address: :auto, name: :auto },
      success_url: organization_subscriptions_success_url(@organization),
      cancel_url: organization_subscriptions_url(@organization)
    )

    redirect_to @checkout_session.url, allow_other_host: true, status: :see_other
  end

  def success
    redirect_to organization_subscriptions_url(@organization)
  end

  def billing_portal
    @portal_session = @organization.payment_processor.billing_portal(
      return_url: organization_subscriptions_url(@organization)
    )
    redirect_to @portal_session.url, allow_other_host: true, status: :see_other
  end

  private

  def sync_subscriptions
    @organization.set_payment_processor :stripe
    @organization.payment_processor.sync_subscriptions(status: "all") unless Rails.env.test?
  end

  def sync_charges
    @organization.set_payment_processor :stripe
    # Sync charges from checkout session for one-time payments
    return unless params[:session_id].present?

    Pay::Stripe::Charge.sync_from_checkout_session(params[:session_id]) unless Rails.env.test?
  end

  def require_billing_enabled
    redirect_to organization_url(@organization) if Rails.application.credentials.dig(:stripe, :private_key).blank?
  end

  def require_current_organization_admin
    redirect_to organization_url(@organization) unless Current.membership.admin?
  end
end
