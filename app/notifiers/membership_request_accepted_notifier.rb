class MembershipRequestAcceptedNotifier < Noticed::Event
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  deliver_by :email do |config|
    config.mailer = "MembershipMailer"
    config.method = :request_accepted_email
    config.args   = -> { [ self ] }
  end

  required_params :organization

  notification_methods do
    def message
      t(".message", organization_name: params[:organization].name)
    end

    def url
      organization_path(params[:organization])
    end
  end
end
