class NotificationsController < ApplicationController
  before_action :load_notifications, only: [ :index ]
  after_action :mark_as_seen, only: [ :index ]

  def index
    @pagy, @notifications = pagy(@notifications, limit: 10)
  end

  private

  def load_notifications
    @notifications = current_user.notifications.newest_first
  end

  def mark_as_seen
    @notifications.unseen.mark_as_seen
  end
end
