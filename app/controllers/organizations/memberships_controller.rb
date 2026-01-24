# frozen_string_literal: true

class Organizations::MembershipsController < Organizations::BaseController
  before_action :set_membership, only: %i[edit update destroy]

  def index
    authorize Membership
    @memberships = @organization.memberships.includes(user: :connected_accounts)
  end

  def edit; end

  def update
    if @membership.update(membership_params)
      flash[:notice] = t(".success")
      respond_to do |format|
        format.html { redirect_to organization_memberships_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_memberships_path(@organization)) }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @membership.try_destroy
      if @membership.user == current_user
        redirect_to user_organizations_path, notice: t(".you_have_left_the_organization")
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
    params.expect(membership: [:role])
  end
end
