# frozen_string_literal: true

class OrganizationsController < ApplicationController
  def index
    discoverable_ids = Organization.discoverable.select(:id)
    user_org_ids = current_user.organizations.select(:id)

    @pagy, @organizations = pagy(
      Organization.where(id: discoverable_ids)
                  .where.not(id: user_org_ids)
                  .with_logo
    )
  end

  def show
    @organization = Organization.discoverable.find(params[:id])
  end
end
