class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || organizations_path
  end

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def current_organization
    @organization if @organization.present? && @organization.persisted?
  end

  helper_method :current_organization
end
