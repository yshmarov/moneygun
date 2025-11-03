# frozen_string_literal: true

module Noticed::NotificationExtensions
  extend ActiveSupport::Concern

  def broadcast_update_to_bell
    broadcast_update_to(
      "notifications_#{recipient.id}",
      target: "notification_count",
      partial: "users/notifications/notifications_count",
      locals: { user: recipient }
    )
  end

  def broadcast_prepend_to_index_list
    broadcast_prepend_to(
      "notifications_index_list_#{recipient.id}",
      target: "notifications",
      partial: "users/notifications/notification",
      locals: { notification: self }
    )
  end
end
