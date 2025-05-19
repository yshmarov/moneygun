class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]

  def index
    @organizations = current_user.organizations.includes(:users)
  end

  def show
    redirect_to params[:redirect_to] if params[:redirect_to].present?
  end

  def new
    @organization = Organization.new
  end

  def edit
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.owner = current_user
    @organization.memberships.build(user: current_user, role: Membership.roles[:admin])

    if @organization.save
      respond_to do |format|
        flash[:notice] = t(".success")
        format.html { redirect_to organization_dashboard_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_dashboard_path(@organization)) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    updated = @organization.update(organization_params)
    coming_from_memberships = request.referer.include?(t("routes.memberships"))

    if updated
      handle_successful_update(coming_from_memberships)
    else
      handle_failed_update(coming_from_memberships)
    end
  end

  def destroy
    @organization.destroy!

    redirect_to organizations_path, notice: t(".success")
  end

  private

  def handle_successful_update(came_from_memberships)
    if came_from_memberships
      redirect_back fallback_location: organization_memberships_path(@organization), notice: t(".success")
    else
      respond_to do |format|
        format.html { redirect_to organization_path(@organization), notice: t(".success") }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_path(@organization)) }
      end
    end
  end

  def handle_failed_update(came_from_memberships)
    if came_from_memberships
      redirect_back fallback_location: organization_memberships_path(@organization), alert: t(".error")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def set_organization
    @organization = Organization.find(params[:id])
    @current_membership ||= current_user.memberships.find_by(organization: @organization)
    authorize @organization
  end

  def organization_params
    params.require(:organization).permit(:name, :logo, :privacy_setting)
  end
end
