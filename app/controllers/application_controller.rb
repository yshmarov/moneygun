# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  before_action :set_current_organizations, if: :user_signed_in?

  set_referral_cookie

  include Pagy::Method
  include CurrentRequest
  include Authentication
  include Authorization
  include Sudo
  include Translation
  include WwwRedirect
  include Agreements::Enforcement

  before_action :require_user_terms, if: :user_signed_in?
  before_action :require_onboarding, if: :user_signed_in?

  helper_method :default_authenticated_path

  private

  def default_authenticated_path
    organizations_path
  end

  def require_user_terms
    require_agreement("user_terms", subject: current_user, location: user_terms_agreement_path)
  end

  def set_current_organizations
    Current.organizations = current_user.organizations.where(memberships: { deactivated_at: nil }).with_logo
  end
end
