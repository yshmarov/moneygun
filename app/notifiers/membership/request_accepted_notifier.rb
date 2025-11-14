# frozen_string_literal: true

# an organization accepted a user's request to join
class Membership::RequestAcceptedNotifier < Noticed::Event
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  deliver_by :email do |config|
    config.mailer = "MembershipMailer"
    config.method = :request_accepted_email
    config.args = -> { [self] }
  end

  required_params :organization

  notification_methods do
    def message
      t("notifiers.membership.request_accepted_notifier.notification.message", organization_name: params[:organization].name)
    end

    def url
      organization_url(params[:organization])
    end

    def icon
      "✅"
    end
  end
end
