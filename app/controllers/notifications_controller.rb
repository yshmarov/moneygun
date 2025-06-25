class NotificationsController < ApplicationController
  before_action :set_notification, only: [ :show ]
  after_action :mark_as_seen, only: [ :show ]

  def index
    @pagy, @notifications = pagy(current_user.notifications.newest_first)
  end

  def show
    redirect_to action: :index unless turbo_frame_request?
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to notifications_path
  end

  def mark_as_seen
    @notification.mark_as_seen
  end
end
