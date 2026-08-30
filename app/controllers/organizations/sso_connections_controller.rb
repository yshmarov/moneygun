# frozen_string_literal: true

class Organizations::SsoConnectionsController < Organizations::BaseController
  before_action :set_connection

  def show
    authorize @connection
    require_sudo(:manage_identity)
  end

  def create
    authorize @connection, :create?
    return if require_sudo(:manage_identity)

    save_connection
  end

  def update
    authorize @connection
    return if require_sudo(:manage_identity)

    save_connection
  end

  def destroy
    authorize @connection
    return if require_sudo(:manage_identity)

    @connection.destroy!
    redirect_to organization_sso_connection_path(@organization)
  end

  private

  def set_connection
    @connection = @organization.sso_connection || @organization.build_sso_connection
  end

  def save_connection
    if @connection.update(connection_params)
      redirect_to organization_sso_connection_path(@organization)
    else
      render :show, status: :unprocessable_content
    end
  end

  def connection_params
    params.expect(sso_connection: %i[enabled idp_entity_id idp_sso_url idp_cert enforced jit_provisioning default_membership_role])
  end
end
