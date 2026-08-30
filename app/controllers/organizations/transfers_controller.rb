# frozen_string_literal: true

class Organizations::TransfersController < Organizations::BaseController
  skip_after_action :verify_authorized
  before_action :authorize_organization_owner!
  before_action -> { require_sudo(:transfer_organization) }, only: :update

  def show; end

  def update
    if @organization.transfer_ownership(transfer_params[:user_id])
      flash[:notice] = t(".success")

      respond_to do |format|
        format.html { redirect_to organization_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_path(@organization)) }
      end
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def transfer_params
    params.expect(transfer: [:user_id])
  end
end
