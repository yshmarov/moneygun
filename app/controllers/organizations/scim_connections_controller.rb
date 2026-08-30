# frozen_string_literal: true

class Organizations::ScimConnectionsController < Organizations::BaseController
  before_action :set_connection

  def show
    authorize policy_record
    return if require_sudo(:manage_identity)

    @generated_token = flash[:generated_token]
  end

  def create
    authorize policy_record, :create?
    return if require_sudo(:manage_identity)

    connection = @organization.create_scim_connection!(connection_params)
    redirect_to organization_scim_connection_path(@organization), flash: { generated_token: connection.token }
  end

  def update
    authorize @connection
    return if require_sudo(:manage_identity)

    token = @connection.regenerate_token! if ActiveModel::Type::Boolean.new.cast(params[:regenerate])
    if @connection.update(connection_params)
      redirect_to organization_scim_connection_path(@organization), flash: { generated_token: token }
    else
      render :show, status: :unprocessable_content
    end
  end

  def destroy
    authorize @connection
    return if require_sudo(:manage_identity)

    @connection.destroy!
    redirect_to organization_scim_connection_path(@organization)
  end

  private

  def set_connection
    @connection = @organization.scim_connection
  end

  def policy_record
    @connection || ScimConnection.new(organization: @organization)
  end

  def connection_params
    params.permit(scim_connection: %i[enabled default_membership_role]).fetch(:scim_connection, {})
  end
end
