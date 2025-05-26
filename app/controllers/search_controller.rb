class SearchController < ApplicationController
  def index
    @organizations = if params[:query].present?
      current_user.organizations.where("name ILIKE ?", "%#{params[:query]}%")
    else
      Organization.none
    end
  end
end
