# frozen_string_literal: true

class Organizations::SentInvitationsController < Organizations::BaseController
  before_action :set_invitation, only: %i[destroy]

  def index
    authorize Membership, :create?
    @pagy, @invitations = pagy(@organization.sent_invitations.pending)
  end

  def new
    authorize Membership, :create?
    @membership_invitation = MembershipInvitation.new(organization: @organization)
  end

  def create
    authorize Membership, :create?
    @membership_invitation = MembershipInvitation.new(
      email: params.dig(:membership_invitation, :email),
      organization: @organization,
      inviter: current_user
    )

    if @membership_invitation.save
      respond_to do |format|
        flash[:notice] = t(".success", email: @membership_invitation.email)
        format.html { redirect_to organization_memberships_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_memberships_path(@organization)) }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    authorize Membership, :destroy?
    @invitation.destroy
    redirect_to organization_sent_invitations_path(@organization), notice: t(".success")
  end

  private

  def set_invitation
    @invitation = @organization.sent_invitations.find(params[:id])
  end
end
