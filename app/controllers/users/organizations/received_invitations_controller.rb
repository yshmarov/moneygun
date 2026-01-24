# frozen_string_literal: true

class Users::Organizations::ReceivedInvitationsController < ApplicationController
  before_action :set_invitation, only: %i[accept decline]

  def index
    @pagy, @organizations = pagy(current_user.organizations_with_pending_invitations)
  end

  def accept
    if @invitation.approve!(completed_by: current_user)
      redirect_to organization_dashboard_path(@invitation.organization), notice: t("invitations.accept.success")
    else
      redirect_to user_organizations_received_invitations_path, alert: @invitation.errors.full_messages.to_sentence
    end
  end

  def decline
    if @invitation.reject!(completed_by: current_user)
      redirect_back_or_to(user_organizations_received_invitations_path, notice: t("invitations.decline.success"))
    else
      redirect_to user_organizations_received_invitations_path, alert: @invitation.errors.full_messages.to_sentence
    end
  end

  private

  def set_invitation
    @invitation = current_user.received_invitations.pending.find(params[:id])
  end
end
