class Organizations::MembershipsController < Organizations::BaseController
  before_action :set_membership, only: [ :edit, :update, :destroy ]

  def index
    authorize Membership
    @memberships = @organization.memberships.includes(:user)
  end

  def new
    authorize @organization.memberships.new
    @form = MembershipInvitation.new(organization: @organization, role: Membership.roles[:member])
  end

  def create
    authorize @organization.memberships.new
    @form = MembershipInvitation.new(email: params.dig(:membership_invitation, :email), role: params.dig(:membership_invitation, :role), organization: @organization, inviter: current_user)

    if @form.save
      redirect_to organization_memberships_path(@organization), notice: t(".success", email: @form.email)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @membership.update(membership_params)
      redirect_to organization_memberships_path(@organization), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @membership.try_destroy
      if @membership.user == current_user
        redirect_to organizations_path, notice: t(".you_have_left_the_organization")
      else
        redirect_to organization_memberships_path(@organization), notice: t(".user_removed_from_organization")
      end
    else
      redirect_to organization_memberships_path(@organization), alert: t(".failed_to_remove_user_from_organization")
    end
  end

  private

  def set_membership
    @membership = @organization.memberships.find(params[:id])
    authorize @membership
  end

  def membership_params
    params.require(:membership).permit(:role)
  end
end
