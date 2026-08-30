# frozen_string_literal: true

class Membership::InvitationAcceptedNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"
  required_params :organization, :email

  notification_methods do
    def message
      t("notifiers.membership.invitation_accepted_notifier.notification.message", email: params[:email], organization_name: params[:organization_name] || params[:organization].name)
    end

    def url
      organization_memberships_url(params[:organization])
    end

    def icon
      "✅"
    end
  end
end
