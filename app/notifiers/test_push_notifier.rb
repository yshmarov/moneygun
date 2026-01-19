# frozen_string_literal: true

# Sends a test push notification to the user's registered devices
class TestPushNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "Noticed::NotificationChannel"
    config.stream = -> { recipient }
    # config.message = :to_websocket
  end

  deliver_by :action_push_native do |config|
    config.devices = -> { recipient.push_devices }
    config.if = -> { recipient.push_devices.any? }
    config.format = lambda {
      {
        title: "Moneygun",
        body: "Test push notification sent at #{Time.current.strftime('%H:%M:%S')}",
        badge: recipient.unseen_notifications_count
      }
    }
    config.with_apple = lambda {
      { aps: { category: "observable" } }
    }
    config.with_google = lambda {
      {}
    }
    config.with_data = lambda {
      { path: "/users/notifications" }
    }
  end

  def message
    "Test push notification sent"
  end

  def url
    user_notifications_path
  end
end
