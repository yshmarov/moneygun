class Organizations::RefillsController < Organizations::BaseController
  def index
    @payment_methods = @organization.payment_processor.payment_methods
  end

  def charges
    @charges = @organization.payment_processor.charges.order(created_at: :desc)
  end

  def transactions
    @transactions = @organization.wallet.transactions.order(created_at: :desc)
  end

  # POST /credits/add_payment_method
  def add_payment_method
    @organization.set_payment_processor :stripe
    session = @organization.payment_processor.checkout(
      mode: "setup",
      currency: UsageCredits.credit_packs.first.second.price_currency,
      success_url: organization_refills_url(@organization),
      cancel_url: organization_refills_url(@organization),
      customer_update: { address: :auto, name: :auto },
      tax_id_collection: { enabled: true }
    )
    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  # POST /credits/charge_payment_method
  def charge_payment_method
    @payment_methods = Stripe::PaymentMethod.list(customer: @organization.payment_processor.processor_id)
    stripe_payment_method_id = @payment_methods.first.id

    if stripe_payment_method_id.blank?
      flash[:alert] = "Please add a payment method first."
      return redirect_to organization_refills_url(@organization)
    end

    credit_pack = UsageCredits.find_credit_pack(params[:credit_pack])

    payment_intent = ChargePaymentMethodJob.perform_now(@organization, credit_pack.name)

    if payment_intent.status == "succeeded"
      flash[:notice] = "Payment successful! Your balance has been updated."
    else
      flash[:alert] = "Payment failed. Please try again."
    end
    redirect_to organization_refills_url(@organization)
  end

  def billing_portal
    session = @organization.payment_processor.billing_portal(return_url: organization_refills_url(@organization))
    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def update_auto_refill
    wallet = @organization.wallet
    wallet.update(wallet_params)
    flash[:notice] = "Auto-refill settings updated"
    redirect_to organization_refills_url(@organization)
  end

  def spend_some_credits
    if process_credit_spending
      flash[:notice] = "Credits spent successfully"
    else
      flash[:alert] = "Insufficient credits"
    end
    redirect_to organization_refills_url(@organization)
  end

  def spend_bulk_credits
    if @organization.has_enough_credits_to?(:spend_bulk_credits, units: params[:units].to_i)
      @organization.spend_credits_on(:spend_bulk_credits, units: params[:units].to_i)
      flash[:notice] = "Credits spent successfully"
    else
      flash[:alert] = "Insufficient credits"
    end
    redirect_to organization_refills_url(@organization)
  end

  private

  def process_credit_spending
    return spend_credits if @organization.has_enough_credits_to?(:spend_some_credits)
    return attempt_auto_refill_and_spend if @organization.wallet.can_auto_refill?

    false
  end

  def spend_credits
    @organization.spend_credits_on(:spend_some_credits) do
      # perform some action
    end
  end

  def attempt_auto_refill_and_spend
    ChargePaymentMethodJob.perform_now(@organization, @organization.wallet.auto_refill_credit_pack)
    return false unless @organization.has_enough_credits_to?(:spend_some_credits)

    spend_credits
  end

  def wallet_params
    params.require(:wallet).permit(:auto_refill_enabled, :auto_refill_credit_pack)
  end
end
