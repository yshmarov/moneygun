class Organizations::CreditsController < Organizations::BaseController
  def index
  end

  def create
    session = if params[:credit_pack_id].present?
      handle_credit_pack_purchase
    elsif params[:subscription_plan_id].present?
      handle_subscription_plan_purchase
    end
    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  private

  def handle_credit_pack_purchase
    credit_pack = UsageCredits.find_credit_pack(params[:credit_pack_id])
    credit_pack.create_checkout_session(@organization)
  end

  def handle_subscription_plan_purchase
    subscription_plan = UsageCredits.find_subscription_plan(params[:subscription_plan_id])
    subscription_plan.create_checkout_session(@organization, cancel_url: organization_credits_url(@organization), success_url: organization_credits_url(@organization))
  end
end
