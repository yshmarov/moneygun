# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  before_action :set_current_organizations, if: :user_signed_in?
  before_action :preload_current_user_data, if: :user_signed_in?

  set_referral_cookie

  include Pagy::Backend
  include Authentication
  include Authorization
  include Translation
  include WwwRedirect

  helper_method :default_authenticated_path

  private

  def default_authenticated_path
    root_path
  end

  def set_current_organizations
    Current.organizations = current_user.organizations.with_logo
  end

  def preload_current_user_data
    current_user.identities.load unless current_user.identities.loaded?
  end
end
