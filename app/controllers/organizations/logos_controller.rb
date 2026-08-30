# frozen_string_literal: true

class Organizations::LogosController < Organizations::BaseController
  def destroy
    authorize @organization, :update?

    @organization.logo.purge
    redirect_to edit_organization_path(@organization)
  end
end
