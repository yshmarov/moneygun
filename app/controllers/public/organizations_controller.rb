class Public::OrganizationsController < ApplicationController
  def index
    @organizations = Organization.not_privacy_setting_private - current_user.organizations
  end

  def show
    @organization = Organization.not_privacy_setting_private.find(params[:id])
  end
end
