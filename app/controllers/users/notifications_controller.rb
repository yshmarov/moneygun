# frozen_string_literal: true

class Users::NotificationsController < ApplicationController
  after_action :mark_as_seen, only: [:index]

  def index
    notifications = current_user.notifications.newest_first

    limit = if turbo_frame_request?
              3
            else
              10
            end
    @pagy, @notifications = pagy(notifications, limit:)
  end

  private

  def mark_as_seen
    @notifications.unseen.mark_as_seen
  end
end
