class Organizations::RefillsController < Organizations::BaseController
  def index
    @payment_methods = Stripe::PaymentMethod.list(customer: current_organization.payment_processor.processor_id)
    @charges = Stripe::Charge.list(customer: current_organization.payment_processor.processor_id, limit: 1)
  end

  # POST /credits/add_payment_method
  def add_payment_method
    current_organization.set_payment_processor :stripe
    session = current_organization.payment_processor.checkout(
      mode: "setup",
      currency: UsageCredits.credit_packs.first.second.price_currency,
      success_url: organization_refills_url(current_organization),
      cancel_url: organization_refills_url(current_organization),
      customer_update: { address: :auto, name: :auto },
      tax_id_collection: { enabled: true }
    )
    redirect_to session.url, allow_other_host: true
  end

  # POST /credits/charge_payment_method
  def charge_payment_method
    @payment_methods = Stripe::PaymentMethod.list(customer: current_organization.payment_processor.processor_id)
    stripe_payment_method_id = @payment_methods.first.id

    if stripe_payment_method_id.blank?
      flash[:alert] = "Please add a payment method first."
      return redirect_to organization_refills_url(current_organization)
    end

    credit_pack = UsageCredits.find_credit_pack(params[:credit_pack])

    payment_intent = ChargePaymentMethodJob.perform_now(current_organization, credit_pack)

    if payment_intent.status == "succeeded"
      flash[:notice] = "Payment successful! Your balance has been updated."
    else
      flash[:alert] = "Payment failed. Please try again."
    end
    redirect_to organization_refills_url(current_organization)
  end
end
