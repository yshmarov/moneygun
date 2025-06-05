class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  layout :determine_layout

  before_action :set_current_organizations, if: :user_signed_in?

  set_referral_cookie

  include Authentication
  include Authorization
  include Analytics

  def current_organization
    Current.membership&.organization
  end

  helper_method :current_organization

  def set_current_organizations
    Current.organizations = current_user.organizations
  end

  private

  def determine_layout
    user_signed_in? ? "application" : "marketing"
  end
end
