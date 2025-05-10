# frozen_string_literal: true

class Organizations::MembershipRequestsController < Organizations::BaseController
  before_action :set_membership_request, only: %i[approve reject  ]

  def index
    @membership_requests = @organization.user_requests.pending
  end

  def approve
    @membership_request.approve!(completed_by: current_user)
    redirect_to organization_membership_requests_path(@organization), notice: t("membership_requests.approve.success")
  end

  def reject
    @membership_request.reject!(completed_by: current_user)
    redirect_to organization_membership_requests_path(@organization), notice: t("membership_requests.reject.success")
  end

  private

  def set_membership_request
    @membership_request = @organization.user_requests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_membership_requests_path(@organization), alert: t("membership_requests.errors.not_found")
  end
end
