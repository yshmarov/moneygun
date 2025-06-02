class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]

  def index
    return redirect_to organization_dashboard_path(current_organization) if Rails.application.config_for(:settings).dig(:only_personal_accounts)

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
    if @organization.update(organization_params)
      flash[:notice] = t(".success")
      respond_to do |format|
        format.html { redirect_to organization_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_path(@organization)) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @organization.destroy!

    redirect_to organizations_path, notice: t(".success")
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
    Current.membership ||= current_user.memberships.find_by(organization: @organization)
    authorize @organization
  end

  def organization_params
    params.require(:organization).permit(:name, :logo, :privacy_setting)
  end
end
