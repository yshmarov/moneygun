# frozen_string_literal: true

class Organizations::SsoDomainsController < Organizations::BaseController
  before_action :set_connection

  def create
    authorize @connection, :update?
    return if require_sudo(:manage_identity)

    domain = @connection.sso_domains.new(params.expect(sso_domain: [:domain]))
    flash[:alert] = domain.errors.full_messages.to_sentence unless domain.save
    redirect_to organization_sso_connection_path(@organization)
  end

  def verify
    authorize @connection, :update?
    return if require_sudo(:manage_identity)

    domain = @connection.sso_domains.find(params.expect(:id))
    flash[:alert] = t(".not_found") unless domain.verify!
    redirect_to organization_sso_connection_path(@organization)
  end

  def destroy
    authorize @connection, :update?
    return if require_sudo(:manage_identity)

    @connection.sso_domains.find(params.expect(:id)).destroy!
    redirect_to organization_sso_connection_path(@organization)
  end

  private

  def set_connection
    @connection = @organization.sso_connection || raise(ActiveRecord::RecordNotFound)
  end
end
