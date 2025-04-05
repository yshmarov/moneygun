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
      redirect_to organization_dashboard_path(@organization), notice: t("organizations.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @organization.update(organization_params)
      redirect_to organization_path(@organization), notice: t("organizations.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @organization.destroy!

    redirect_to organizations_path, notice: t("organizations.destroy.success")
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
    @current_membership ||= current_user.memberships.find_by(organization: @organization)
    authorize @organization
  end

  def organization_params
    params.require(:organization).permit(:name, :logo)
  end
end
