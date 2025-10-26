module Noticed::NotificationExtensions
  extend ActiveSupport::Concern

  def broadcast_replace_to_index_count
    broadcast_replace_to(
      "notifications_index_#{recipient.id}",
      target: "notification_index_count",
      partial: "users/notifications/notifications_count",
      locals: { unread: recipient.reload.unseen_notifications_count }
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
