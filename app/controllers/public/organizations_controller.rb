class Public::OrganizationsController < ApplicationController
  def index
    @organizations = Organization.not_privacy_setting_private
  end

  def show
    @organization = Organization.not_privacy_setting_private.find(params[:id])
  end
end
