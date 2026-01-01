# frozen_string_literal: true

# user was removed from an organization
class Membership::RemovalNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  deliver_by :email do |config|
    config.mailer = "MembershipMailer"
    config.method = :removal_email
    config.args = -> { [self] }
    config.message = -> { message }
  end

  deliver_by :action_push_native do |config|
    config.devices = -> { recipient.push_devices }
    config.if = -> { recipient.push_devices.any? }
    config.format = lambda {
      {
        title: "Moneygun",
        body: message,
        badge: recipient.unseen_notifications_count
      }
    }
    config.with_data = -> { { path: url } }
  end

  required_params :organization

  notification_methods do
    def message
      t("notifiers.membership.removal_notifier.notification.message", organization_name: params[:organization].name)
    end

    def url
      organizations_url
    end

    def icon
      "🚪"
    end
  end
end
