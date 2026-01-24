# frozen_string_literal: true

class Users::Organizations::SentJoinRequestsController < ApplicationController
  before_action :set_organization, only: %i[create]

  def index
    @pagy, @organizations = pagy(current_user.organizations_with_pending_join_requests)
  end

  def create
    join_request = MembershipRequest.new(organization: @organization, user: current_user)

    if join_request.save
      notice = @organization.privacy_setting_public? ? t("join_requests.success.access_granted") : t("join_requests.success.access_requested")
      redirect_to organization_path(@organization), notice: notice
    else
      redirect_to organization_path(@organization), alert: join_request.errors.full_messages.join(", ")
    end
  end

  def destroy
    @join_request = current_user.sent_join_requests.pending.find(params[:id])
    @join_request.destroy
    redirect_to user_organizations_sent_join_requests_path, notice: t(".success")
  end

  private

  def set_organization
    @organization = Organization.discoverable.find(params[:organization_id])
  end
end
