# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :masquerade_user!
  end

  private

  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)
    return stored_location if stored_location

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

  # https://github.com/scambra/devise_invitable
  # def after_invite_path_for(resource)
  #   edit_user_invitation_path(resource)
  # end
end
