# incoming invitations to join an organization
class Users::InvitationsController < ApplicationController
  before_action :set_invitation, only: [ :approve, :reject ]

  def index
    invitations = current_user.organization_invitations.pending.includes(:organization)
    @organizations = invitations.map(&:organization)
  end

  def approve
    @invitation.approve!
    redirect_back(fallback_location: user_invitations_path, notice: t("invitations.approve.success"))
  end

  def reject
    @invitation.reject!
    redirect_back(fallback_location: user_invitations_path, notice: t("invitations.reject.success"))
  end

  private

  def set_invitation
    @invitation = current_user.organization_invitations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to user_invitations_path, alert: t("invitations.errors.not_found")
  end
end
