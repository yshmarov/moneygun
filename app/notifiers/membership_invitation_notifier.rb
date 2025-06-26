# invited a user to an organization
class MembershipInvitationNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  deliver_by :email do |config|
    config.mailer = "MembershipMailer"
    config.method = :invitation_email
    config.args   = -> { [ self ] }
  end

  required_params :organization

  notification_methods do
    def message
      t("notifiers.membership_invitation_notifier.notification.message", organization_name: params[:organization].name)
    end

    def url
      user_invitations_url
    end
  end
end
