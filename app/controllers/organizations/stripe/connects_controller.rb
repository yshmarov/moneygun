class Organizations::Stripe::ConnectsController < Organizations::BaseController
  def show
  end

  def setup
    @organization.set_merchant

    url = @organization.merchant_processor.account_link(return_url: organization_stripe_connect_url(@organization), refresh_url: organization_stripe_connect_url(@organization))["url"]
    redirect_to url, allow_other_host: true, status: :see_other
  end

  def dashboard
    return unless @organization.merchant_processor.onboarding_complete?

    url = @organization.merchant_processor.login_link["url"]
    redirect_to url, allow_other_host: true, status: :see_other
  end

  def restart
    @organization.merchant_processor.destroy
    @organization.set_merchant
    redirect_to organization_stripe_connect_path(@organization), status: :see_other
  end
end
