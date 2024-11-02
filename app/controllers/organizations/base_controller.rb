class Organizations::BaseController < ApplicationController
  # the order of the before_actions is important
  before_action :set_organization
  # before_action :authorize_membership!
  before_action :set_current_membership

  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
  end

  # def authorize_membership!
  #   redirect_to root_path, alert: "You are not authorized to perform this action." unless @organization.users.include?(current_user)
  #   raise Pundit::NotAuthorizedError unless @organization.users.include?(current_user)
  # end

  def set_current_membership
    @current_membership ||= current_user.memberships.find_by(organization: @organization)
  end

  def pundit_user
    @current_membership
  end

  # def authorize_organization_admin!
  #   redirect_to organization_path(@organization), alert: "You are not authorized to perform this action." unless @current_membership.admin?
  #   raise Pundit::NotAuthorizedError unless @current_membership.admin?
  # end
end
