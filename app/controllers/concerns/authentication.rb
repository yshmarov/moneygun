module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || if current_user.default_organization.payment_processor.subscribed?
      organization_dashboard_path(current_user.default_organization)
                                     else
      organization_subscriptions_path(current_user.default_organization)
                                     end
  end
end
