# an organization rejected a user's request to join
class Membership::RequestRejectedNotifier < Noticed::Event
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  deliver_by :email do |config|
    config.mailer = "MembershipMailer"
    config.method = :request_rejected_email
    config.args   = -> { [self] }
  end

  required_params :organization

  notification_methods do
    def message
      t("notifiers.membership.request_rejected_notifier.notification.message", organization_name: params[:organization].name)
    end

    def url
      public_organizations_url
    end

    def icon
      "❌"
    end
  end
end
