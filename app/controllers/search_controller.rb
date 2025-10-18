class SearchController < ApplicationController
  def index
    @organizations = if params[:query].present?
                       # Combine user's organizations + public/restricted organizations
                       Organization.where(id: [
                         current_user.organizations.pluck(:id),
                         Organization.discoverable.pluck(:id)
                       ].flatten.uniq)
                                   .where('name ILIKE ?', "%#{params[:query]}%")
                     else
                       Organization.none
                     end
  end
end
