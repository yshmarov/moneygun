class Organizations::DashboardController < Organizations::BaseController
  before_action :require_subscription, only: :paywalled_page

  def index
    if @organization.payment_processor.subscribed?
      redirect_to organization_paywalled_page_path(@organization)
    else
      redirect_to organization_subscriptions_path(@organization)
    end
  end

  def paywalled_page
  end
end
