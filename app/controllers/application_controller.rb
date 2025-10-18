class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  before_action :set_current_organizations, if: :user_signed_in?

  set_referral_cookie

  include Pagy::Backend
  include Authentication
  include Authorization
  include Analytics
  include Translation

  private

  def set_current_organizations
    Current.organizations = current_user.organizations.includes(logo_attachment: :blob)
  end
end
