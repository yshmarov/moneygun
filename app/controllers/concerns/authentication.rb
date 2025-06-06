module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || default_path
  end

  private

  def default_path
    return organization_dashboard_path(current_user.default_organization) if Rails.application.config_for(:settings).dig(:only_personal_accounts)

    organizations_path
  end
end
