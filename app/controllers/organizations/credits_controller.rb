class Organizations::CreditsController < Organizations::BaseController
  def index
    @credit_packs = UsageCredits.credit_packs
    @subscription_plans = UsageCredits.subscription_plans
  end

  def create
    if params[:credit_pack_id].present?
      credit_pack = UsageCredits.find_credit_pack(params[:credit_pack_id])
      session = credit_pack.create_checkout_session(current_organization)
    end
    if params[:subscription_plan_id].present?
      subscription_plan = UsageCredits.find_subscription_plan(params[:subscription_plan_id])
      session = subscription_plan.create_checkout_session(current_organization, cancel_url: organization_credits_url(current_organization), success_url: organization_credits_url(current_organization))
    end
    redirect_to session.url, allow_other_host: true, status: :see_other
  end
end
