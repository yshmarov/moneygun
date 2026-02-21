# frozen_string_literal: true

# Notifies org admins when a user requests to join their organization
class Membership::JoinRequestReceivedNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  required_params :organization, :user_name

  notification_methods do
    def message
      t("notifiers.membership.join_request_received_notifier.notification.message",
        user_name: params[:user_name],
        organization_name: params[:organization].name)
    end

    def url
      organization_received_join_requests_url(params[:organization])
    end

    def icon
      "📬"
    end
  end
end
