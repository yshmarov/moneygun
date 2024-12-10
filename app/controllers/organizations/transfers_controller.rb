class Organizations::TransfersController < Organizations::BaseController
  before_action :authorize_organization_owner!

  def show
  end

  def update
    if @organization.transfer_ownership(params[:user_id])
      redirect_to @organization, notice: "Ownership transferred successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end
end
