class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_current_organizations, if: :user_signed_in?

  def after_sign_in_path_for(resource)
    return stored_location_for(resource) if stored_location_for(resource)

    if b2b_enabled?
      organizations_path
    else
      # When B2B is disabled, redirect to the user's default organization
      default_org = resource.organizations.first
      default_org ? organization_dashboard_path(default_org) : organizations_path
    end
  end

  include Authorization

  def current_organization
    Current.membership&.organization
  end

  helper_method :current_organization

  def set_current_organizations
    Current.organizations = current_user.organizations
  end

  private

  def b2b_enabled?
    Rails.application.config_for(:settings).dig(:app_features, :b2b) == true
  end
end
