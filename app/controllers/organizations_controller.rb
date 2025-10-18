class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]

  def index
    @pagy, @organizations = pagy(current_user.organizations.includes(:users))
  end

  def show; end

  def new
    @organization = Organization.new
  end

  def edit; end

  def create
    @organization = Organization.new(organization_params)
    @organization.owner = current_user

    if @organization.save
      respond_to do |format|
        flash[:notice] = t('.success')
        format.html { redirect_to organization_dashboard_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_dashboard_path(@organization)) }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @organization.update(organization_params)
      flash[:notice] = t('.success')
      respond_to do |format|
        format.html { redirect_to edit_organization_path(@organization) }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @organization.destroy
      redirect_to organizations_path, notice: t('.success')
    else
      redirect_to organization_path(@organization), alert: t('.error')
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
    Current.membership ||= current_user.memberships.find_by(organization: @organization)
    Current.organization = Current.membership&.organization
    authorize @organization
  end

  def organization_params
    params.expect(organization: %i[name logo privacy_setting])
  end

  def pundit_user
    return super if Current.membership.nil?

    Current.membership
  end
end
