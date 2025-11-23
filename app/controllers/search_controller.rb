# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    query = params.dig(:search, :query)
    @organizations = if query.present?
                       user_org_ids = current_user.organizations.select(:id)
                       discoverable_ids = Organization.discoverable.select(:id)

                       Organization.where(id: user_org_ids)
                                   .or(Organization.where(id: discoverable_ids))
                                   .where("name ILIKE ?", "%#{query}%")
                     else
                       Organization.none
                     end
  end
end
