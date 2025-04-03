class Organizations::DashboardController < Organizations::BaseController
  before_action :require_subscription, only: :paywalled_page

  def index
  end

  def paywalled_page
    render json: { message: "Congrats! If you see this, you're subscribed." }
  end
end
