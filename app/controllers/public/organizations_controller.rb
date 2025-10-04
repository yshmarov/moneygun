class Public::OrganizationsController < ApplicationController
  def index
    organizations_ids = Organization.discoverable.pluck(:id) - current_user.organizations.pluck(:id)
    @pagy, @organizations = pagy(Organization.where(id: organizations_ids).includes(logo_attachment: :blob))
  end

  def show
    @organization = Organization.discoverable.find(params[:id])
  end
end
