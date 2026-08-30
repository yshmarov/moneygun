# frozen_string_literal: true

class Users::InvitationsController < ApplicationController
  layout "centered", only: :show
  skip_before_action :require_onboarding
  allow_unauthenticated_access only: :show

  before_action :set_invitation, only: %i[accept decline]

  def index
    @invitations = current_user.received_invitations.pending.includes(:organization)
  end

  def show
    return redirect_to_sign_in_with_prefill unless authenticated?

    @invitation = current_user.received_invitations.pending.find_by!(token: params.expect(:id))
    authorize @invitation
    @organization = @invitation.organization
  end

  def accept
    authorize @invitation
    organization = @invitation.organization
    @invitation.accept!(actor_user: current_user)
    redirect_to organization_dashboard_path(organization)
  rescue Invitation::TransitionError
    redirect_to user_invitations_path, alert: t(".unavailable")
  end

  def decline
    authorize @invitation
    @invitation.decline!(actor_user: current_user)
    redirect_to path_after_invitation
  rescue Invitation::TransitionError
    redirect_to user_invitations_path, alert: t(".unavailable")
  end

  private

  def set_invitation
    @invitation = current_user.received_invitations.pending.find_by!(token: params.expect(:id))
  end

  def redirect_to_sign_in_with_prefill
    invitation = Invitation.pending.find_by(token: params.expect(:id))
    session[:prefill_email_address] = invitation.email if invitation
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def path_after_invitation
    next_invitation = current_user.received_invitations.pending.first
    next_invitation ? user_invitation_path(next_invitation) : default_authenticated_path
  end
end
