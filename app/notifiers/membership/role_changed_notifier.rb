# frozen_string_literal: true

# notifies a user when their role in an organization has changed
class Membership::RoleChangedNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  required_params :organization

  notification_methods do
    def message
      t("notifiers.membership.role_changed_notifier.notification.message",
        organization_name: params[:organization].name,
        role: params[:role])
    end

    def url
      organization_path(params[:organization])
    end

    def icon
      "🔄"
    end
  end
end
