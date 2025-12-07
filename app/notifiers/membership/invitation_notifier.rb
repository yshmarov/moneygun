# frozen_string_literal: true

# invited a user to an organization
class Membership::InvitationNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  deliver_by :email do |config|
    config.mailer = "MembershipMailer"
    config.method = :invitation_email
    config.args = -> { [self] }
  end

  required_params :organization

  notification_methods do
    def message
      t("notifiers.membership.invitation_notifier.notification.message", organization_name: params[:organization].name)
    end

    def url
      # URL for internal notification system (when user clicks notification)
      user_organizations_invitations_url
    end

    def email_url
      if recipient.confirmed?
        user_organizations_invitations_url
      elsif recipient.invitation_token.present?
        accept_user_invitation_url(invitation_token: recipient.invitation_token)
      end
    end

    def icon
      "📩"
    end
  end
end
