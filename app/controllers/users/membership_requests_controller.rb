# frozen_string_literal: true

class Users::MembershipRequestsController < ApplicationController
  before_action :set_organization

  def create
    request = MembershipRequest.new(organization: @organization, user: current_user)
    if request.save
      flash[:notice] = t("membership_requests.success")
    else
      flash[:alert] = request.errors.full_messages.join(", ")
    end

    render turbo_stream: [
      turbo_stream.replace("organization_#{@organization.id}",
                          partial: "discovers/organization",
                          locals: { organization: @organization }),
      turbo_stream.update("flash", partial: "shared/flash")
    ]
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: discover_path, alert: t("organizations.errors.not_found"))
  end
end
