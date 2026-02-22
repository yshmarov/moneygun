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

    invitation = resource.received_invitations.pending.first
    return user_organizations_received_invitation_path(invitation) if invitation

    if session[:new_user]
      session.delete(:new_user)
      # You can send new users to onboarding, billing, or somewhere else
      root_path
    else
      default_authenticated_path
    end
  end

  def path_after_invitation(user)
    next_invitation = user.received_invitations.pending.first
    return user_organizations_received_invitation_path(next_invitation) if next_invitation

    default_authenticated_path
  end

  def default_authenticated_path
    organizations_path
  end
end
