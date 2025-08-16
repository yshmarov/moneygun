class Organizations::DashboardController < Organizations::BaseController
  before_action :require_subscription, only: :paywalled_page

  def index
  end

  def paywalled_page
    render inline: "Congrats! If you see this, you're subscribed.", layout: "application"
  end
end
