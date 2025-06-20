class Organizations::InvitationsController < Organizations::BaseController
  before_action :set_invitation, only: %i[destroy]

  def index
    authorize Membership, :create?
    @invitations = @organization.user_invitations.pending
  end

  def new
    authorize Membership, :create?
    @form = MembershipInvitation.new(organization: @organization)
  end

  def create
    authorize Membership, :new?
    @form = MembershipInvitation.new(email: params.dig(:membership_invitation, :email), organization: @organization, inviter: current_user)

    if @form.save
      recipient = User.find_by(email: @form.email)
      if recipient
        MembershipInvitationNotifier.with(organization: @organization).deliver(recipient)
      end
      respond_to do |format|
        flash[:notice] = t(".success", email: @form.email)
        format.html { redirect_to organization_memberships_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_memberships_path(@organization)) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize Membership, :destroy?
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
