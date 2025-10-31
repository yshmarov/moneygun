# frozen_string_literal: true

module Noticed::NotificationExtensions
  extend ActiveSupport::Concern

  def broadcast_replace_to_index_count
    Turbo::StreamsChannel.broadcast_replace_to(
      "notifications_#{recipient.id}",
      target: "notification_count",
      partial: "users/notifications/notifications_count",
      locals: { unread: recipient.reload.unseen_notifications_count }
    )
  end

  def broadcast_prepend_to_index_list
    Turbo::StreamsChannel.broadcast_prepend_to(
      "notifications_#{recipient.id}",
      target: "notifications",
      partial: "users/notifications/notification",
      locals: { notification: self }
    )
  end
end
