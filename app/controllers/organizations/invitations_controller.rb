class Organizations::InvitationsController < Organizations::BaseController
  before_action :set_invitation, only: %i[destroy]

  def index
    @invitations = @organization.user_invitations.pending
  end

  def destroy
    @invitation.destroy
    redirect_to organization_invitations_path(@organization), notice: t("organizations.invitations.destroy.success")
  end

  private

  def set_invitation
    @invitation = @organization.user_invitations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_invitations_path(@organization), alert: t("organizations.invitations.errors.not_found")
  end
end
