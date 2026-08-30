# frozen_string_literal: true

class Membership::OrganizationDeletedNotifier < ApplicationNotifier
  required_params :organization_name

  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  deliver_by :email do |config|
    config.mailer = "MembershipMailer"
    config.method = :organization_deleted
    config.args = -> { [self] }
  end

  notification_methods do
    def message
      t("notifiers.membership.organization_deleted_notifier.notification.message", organization_name: params[:organization_name])
    end

    def url
      organizations_url
    end

    def icon
      "svg/trash.svg"
    end
  end
end
