# frozen_string_literal: true

# invited a user to an organization
class Membership::InvitationNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  required_params :organization

  notification_methods do
    def message
      t("notifiers.membership.invitation_notifier.notification.message", organization_name: params[:organization].name)
    end

    def url
      params[:invitation] ? user_invitation_url(params[:invitation]) : user_invitations_url
    end

    def icon
      "📩"
    end
  end
end
