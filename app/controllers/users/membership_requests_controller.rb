# outgoing requests to join an organization
class Users::MembershipRequestsController < ApplicationController
  before_action :set_organization, only: %i[create]

  def index
    organization_ids = current_user.organization_requests.pending.pluck(:organization_id)
    @pagy, @organizations = pagy(Organization.where(id: organization_ids))
  end

  def create
    request = MembershipRequest.new(organization: @organization, user: current_user)
    if request.save
      flash.now[:notice] = if @organization.privacy_setting_public?
                             t('membership_requests.success.access_granted')
                           else
                             t('membership_requests.success.access_requested')
                           end
    else
      flash.now[:alert] = request.errors.full_messages.join(', ')
    end

    respond_to do |format|
      format.html { redirect_to public_organization_path(@organization) }
      format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(public_organization_path(@organization)) }
    end
  end

  def destroy
    @organization_request = current_user.organization_requests.pending.find(params[:id])
    @organization_request.destroy
    redirect_to user_membership_requests_path, notice: t('.success')
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: public_organizations_path, alert: t('organizations.errors.not_found'))
  end
end
