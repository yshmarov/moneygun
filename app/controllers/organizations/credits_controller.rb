class Organizations::CreditsController < Organizations::BaseController
  def index
    @credit_packs = UsageCredits.credit_packs
    @subscription_plans = UsageCredits.subscription_plans
  end

  def create
    credit_pack = UsageCredits.find_credit_pack(:starter)
    session = credit_pack.create_checkout_session(current_user)
    redirect_to session.url
  end
end
