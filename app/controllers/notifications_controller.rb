class NotificationsController < ApplicationController
  def index
    @pagy, @notifications = pagy(current_user.notifications.newest_first)
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read
    redirect_to notification.url || root_path
  end
end
