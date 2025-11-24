# frozen_string_literal: true

# incoming invitations to join an organization
class Users::InvitationsController < ApplicationController
  before_action :set_invitation, only: %i[approve reject]

  def index
    organization_ids = current_user.organization_invitations.pending.select(:organization_id)
    @pagy, @organizations = pagy(Organization.where(id: organization_ids))
  end

  def approve
    @invitation.approve!
    redirect_back_or_to(user_invitations_path, notice: t("invitations.approve.success"))
  end

  def reject
    @invitation.reject!
    redirect_back_or_to(user_invitations_path, notice: t("invitations.reject.success"))
  end

  private

  def set_invitation
    @invitation = current_user.organization_invitations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to user_invitations_path, alert: t("invitations.errors.not_found")
  end
end
