# frozen_string_literal: true

# notifies organization admins when a user requests to join
class Membership::JoinRequestNotifier < Noticed::Event
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  required_params :organization, :user

  notification_methods do
    def message
      t("notifiers.membership.join_request_notifier.notification.message",
        user_email: params[:user].email,
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
