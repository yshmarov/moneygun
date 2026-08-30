# frozen_string_literal: true

class Membership::ReactivationNotifier < ApplicationNotifier
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  required_params :organization

  notification_methods do
    def message
      organization_name = params[:organization_name] || params[:organization]&.name || I18n.t("notifiers.organization_fallback")
      t("notifiers.membership.reactivation_notifier.notification.message", organization_name: organization_name)
    end

    def url
      organization_url(params[:organization]) if params[:organization]
    end

    def icon
      "🔓"
    end
  end
end
