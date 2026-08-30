# frozen_string_literal: true

module Scim
  class UsersController < Scimitar::ActiveRecordBackedResourcesController
    rate_limit to: 300, within: 1.minute,
               by: -> { Digest::SHA256.hexdigest(request.authorization.to_s) },
               with: lambda {
                 render json: { schemas: ["urn:ietf:params:scim:api:messages:2.0:Error"], status: "429", detail: "Rate limit exceeded." },
                        status: :too_many_requests, content_type: "application/scim+json"
               }

    def create
      with_scim_resource do |resource|
        require_consent_for_existing_account!(scim_username(resource))
        membership = storage_class.transaction { upsert_from_scim(resource) }
        render json: record_to_scim(membership), status: :created
      end
    end

    def destroy
      super do |membership|
        deactivate!(membership)
      end
    end

    protected

    def storage_class = Membership

    def storage_scope
      Current.organization.memberships.joins(:user).preload(:user)
    end

    def handle_on_save_exception(record, exception = RuntimeError.new("Unknown"))
      raise Scimitar::ErrorResponse.new(status: 409, detail: record.errors.full_messages.to_sentence) if record.errors.where(:base).any?

      super
    end

    private

    def upsert_from_scim(resource)
      email = scim_username(resource)
      existing = Current.organization.memberships.joins(:user).find_by(users: { email: email })

      if existing.nil?
        provision(resource)
      elsif existing.deactivated?
        reactivate(existing, resource)
      else
        raise Scimitar::ErrorResponse.new(status: 409, scimType: "uniqueness", detail: "User #{email} is already provisioned in this organization.")
      end
    end

    def provision(resource)
      membership = storage_class.new(
        organization: Current.organization,
        role: Current.scim_connection&.default_membership_role || "member",
        provisioned_via: "scim"
      )
      membership.from_scim!(scim_hash: resource.as_json)
      save!(membership)
      membership
    end

    def require_consent_for_existing_account!(email)
      return if email.blank?
      return unless User.exists?(email: email)
      return if Current.organization.memberships.joins(:user).exists?(users: { email: email })

      unless Current.organization.invitations.pending.for_email(email).exists?
        invitation = Current.organization.invitations.create!(email: email, role: Current.scim_connection&.default_membership_role || "member")
        invitation.log_created!(actor: nil)
        invitation.deliver
      end
      raise Scimitar::ErrorResponse.new(status: 409, scimType: "uniqueness",
                                        detail: "This account must accept its organization invitation before provisioning.")
    end

    def scim_username(resource)
      resource.userName.to_s.strip.downcase
    end

    def reactivate(membership, resource)
      membership.provisioned_via = "scim"
      membership.scim_external_id = resource.externalId if resource.externalId.present?
      membership.deactivated_at = nil
      save!(membership)
      membership
    end

    def deactivate!(membership)
      return if membership.deactivated?

      membership.update(deactivated_at: Time.current) || handle_on_save_exception(membership)
    end
  end
end
