class Organizations::TransfersController < Organizations::BaseController
  before_action :authorize_organization_owner!

  def show
  end

  def update
    if @organization.transfer_ownership(params[:user_id])
      flash[:notice] = t('.success')

      respond_to do |format|
        format.html { redirect_to organization_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_path(@organization)) }
      end
    else
      render :show, status: :unprocessable_content
    end
  end
end
