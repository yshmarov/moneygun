# frozen_string_literal: true

class Organizations::ReceivedJoinRequestsController < Organizations::BaseController
  before_action :set_join_request, only: %i[approve reject]

  def index
    authorize Membership, :create?
    @pagy, @join_requests = pagy(@organization.received_join_requests.pending)
  end

  def approve
    authorize Membership, :create?
    if @join_request.approve!(completed_by: current_user)
      redirect_to organization_received_join_requests_path(@organization), notice: t("join_requests.approve.success")
    else
      redirect_to organization_received_join_requests_path(@organization), alert: @join_request.errors.full_messages.to_sentence
    end
  end

  def reject
    authorize Membership, :create?
    if @join_request.reject!(completed_by: current_user)
      redirect_to organization_received_join_requests_path(@organization), notice: t("join_requests.reject.success")
    else
      redirect_to organization_received_join_requests_path(@organization), alert: @join_request.errors.full_messages.to_sentence
    end
  end

  private

  def set_join_request
    @join_request = @organization.received_join_requests.find(params[:id])
  end
end
