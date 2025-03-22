class Organizations::DashboardController < Organizations::BaseController
  before_action :require_subscription, only: :paywalled_page

  def index
  end

  def paywalled_page
    render json: { message: "Congrats! If you see this, you're subscribed." }
  end

  private

  def require_subscription
    unless current_organization.payment_processor.subscribed?
      flash[:alert] = "You need to subscribe to access this page."
      redirect_to organization_subscriptions_url(current_organization)
    end
  end
end
