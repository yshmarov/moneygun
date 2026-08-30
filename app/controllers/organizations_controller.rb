# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include OrganizationPrefill
  include OrganizationAgreements

  layout "centered", only: %i[new create]

  before_action :set_organization, only: %i[show edit update destroy]
  before_action :require_organization_agreement, only: %i[show edit update destroy]
  before_action -> { require_sudo(:destroy_organization) }, only: :destroy

  def index
    organizations = current_user.organizations.where(memberships: { deactivated_at: nil })
    @pagy, @organizations = pagy(organizations.with_logo.includes(:users, :memberships, :invitations, :received_join_requests))
  end

  def show; end

  def new
    @organization = Organization.new

    if params[:website].present?
      prefill_organization_from_website(@organization, params[:website])
      @show_form = true
    elsif params[:skip].present?
      @show_form = true
    end
  end

  def edit; end

  def create
    @organization = Organization.new(organization_params)
    @organization.owner = current_user

    if @organization.save
      redirect_to organization_dpa_agreement_path(@organization)
    else
      @show_form = true
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @organization.update(organization_params)
      respond_to do |format|
        format.html { redirect_to edit_organization_path(@organization) }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @organization.undeletable_reasons.any?
      redirect_to edit_organization_path(@organization), alert: t(".has_active_subscription")
    elsif @organization.erase!
      redirect_to organizations_path
    else
      redirect_to edit_organization_path(@organization), alert: t(".error")
    end
  end

  private

  def set_organization
    @organization = current_user.organizations.where(memberships: { deactivated_at: nil }).find(params[:id])
    Current.membership = current_user.memberships.active.find_by(organization: @organization)
    Current.organization = Current.membership&.organization
    authorize @organization
  rescue ActiveRecord::RecordNotFound
    redirect_to default_authenticated_path, alert: t("shared.errors.not_authorized")
  end

  def organization_params
    params.expect(organization: %i[name logo privacy_setting website])
  end

  def pundit_user
    Current.membership || super
  end
end
