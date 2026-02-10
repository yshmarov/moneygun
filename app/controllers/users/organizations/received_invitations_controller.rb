# frozen_string_literal: true

class Users::Organizations::ReceivedInvitationsController < ApplicationController
  before_action :set_invitation, only: %i[show accept decline]

  def index
    @pagy, @organizations = pagy(current_user.organizations_with_pending_invitations)
  end

  def show
    @organization = @invitation.organization
  end

  def accept
    @invitation.approve!
    redirect_to organization_dashboard_path(@invitation.organization), notice: t("invitations.accept.success")
  end

  def decline
    @invitation.reject!
    redirect_back_or_to(user_organizations_received_invitations_path, notice: t("invitations.decline.success"))
  end

  private

  def set_invitation
    @invitation = current_user.received_invitations.pending.find(params[:id])
  end
end
