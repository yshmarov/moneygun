# frozen_string_literal: true

class Users::MembershipRequestsController < ApplicationController
  before_action :set_organization

  def create
    request = MembershipRequest.new(organization: @organization, user: current_user)

    if request.save
      if request.organization.privacy_setting_public?
        redirect_to organization_path(request.organization), notice: t("membership_requests.success")
      else
        redirect_back(fallback_location: discover_path, notice: t("membership_requests.success"))
      end
    else
      redirect_back(fallback_location: discover_path, alert: request.errors.full_messages.join(", "))
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: discover_path, alert: t("organizations.errors.not_found"))
  end
end
