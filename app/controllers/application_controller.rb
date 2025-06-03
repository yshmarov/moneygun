class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_organizations, if: :user_signed_in?
  before_action :current_organization, if: :signed_in?

  set_referral_cookie

  include Authentication
  include Authorization

  def current_organization
    Current.membership&.organization
  end

  helper_method :current_organization

  def set_current_organizations
    Current.organizations = current_user.organizations
  end

  def current_organization
    return unless Rails.application.config_for(:settings).dig(:only_personal_accounts)

    @current_organization ||= current_user&.organizations&.first
  end
end
