# frozen_string_literal: true

class Organizations::DashboardController < Organizations::BaseController
  skip_after_action :verify_authorized
  before_action :require_subscription, only: :paywalled_page

  def index; end

  def paywalled_page
    render inline: "Congrats! If you see this, you're subscribed.", layout: "application"
  end
end
