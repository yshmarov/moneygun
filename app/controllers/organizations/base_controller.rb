class Organizations::BaseController < ApplicationController
  # the order of the before_actions is important
  before_action :set_organization
  # before_action :authorize_membership!
  before_action :set_current_membership
  # ensure Pundit "authorize" is called for every controller action
  # after_action :verify_authorized

  # def authorize_membership!
  #   redirect_to root_path, alert: I18n.t("shared.errors.not_authorized") unless @organization.users.include?(current_user)
  #   raise Pundit::NotAuthorizedError unless @organization.users.include?(current_user)
  # end

  # def authorize_organization_admin!
  #   redirect_to organization_path(@organization), alert: I18n.t("shared.errors.not_authorized") unless Current.membership.admin?
  #   raise Pundit::NotAuthorizedError unless Current.membership.admin?
  # end

  def authorize_organization_owner!
    redirect_to organization_path(@organization), alert: I18n.t("shared.errors.not_authorized") unless @organization.owner?(current_user)
  end

  def require_subscription
    return if current_organization.payment_processor.subscribed?

    flash[:alert] = t("shared.errors.not_subscribed")
    redirect_to organization_subscriptions_url(current_organization)
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organizations_path, alert: t("shared.errors.not_authorized")
  end

  def set_current_membership
    Current.membership ||= current_user.memberships.find_by(organization: @organization)
  end

  def pundit_user
    Current.membership
  end
end
