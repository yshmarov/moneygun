class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || organizations_path
  end

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = t("shared.errors.not_authorized")
    redirect_to(request.referer || root_path)
  end

  def current_organization
    @current_membership&.organization
  end

  helper_method :current_organization
end
