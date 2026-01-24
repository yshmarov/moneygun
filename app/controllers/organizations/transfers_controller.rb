# frozen_string_literal: true

class Organizations::TransfersController < Organizations::BaseController
  skip_after_action :verify_authorized
  before_action :authorize_organization_owner!

  def show; end

  def update
    if @organization.transfer_ownership(params[:user_id])
      flash[:notice] = t(".success")

      respond_to do |format|
        format.html { redirect_to organization_dashboard_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_dashboard_path(@organization)) }
      end
    else
      render :show, status: :unprocessable_content
    end
  end
end
