class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_current_organizations, if: :user_signed_in?

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || organizations_path
  end

  include Authorization

  def current_organization
    Current.membership&.organization
  end

  helper_method :current_organization

  def set_current_organizations
    Current.organizations = current_user.organizations
  end
end
