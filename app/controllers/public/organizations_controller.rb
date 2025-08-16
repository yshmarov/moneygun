class Public::OrganizationsController < ApplicationController
  def index
    @organizations = Organization.discoverable - current_user.organizations
  end

  def show
    @organization = Organization.discoverable.find(params[:id])
  end
end
