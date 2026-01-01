# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :masquerade_user!
  end

  private

  def after_sign_in_path_for(resource)
    return "/reset_app" if hotwire_native_app?

    stored_location = stored_location_for(resource)
    return stored_location if stored_location

    # Redirect users with pending invitations to their invitations page
    return user_organizations_received_invitations_path if resource.received_invitations.pending.any?

    if resource.organizations.any?
      session.delete(:new_user) if session[:new_user]
      organization_path(resource.organizations.first)
    elsif session[:new_user]
      session.delete(:new_user)
      # You can send new users to onboarding, billing, or somewhere else
      root_path
    else
      stored_location_for(resource) || root_path
    end
  end
end
