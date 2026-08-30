# frozen_string_literal: true

class Avo::Resources::SsoConnection < Avo::BaseResource
  self.includes = %i[organization sso_domains]
  self.title = -> { record.organization.name }

  def fields
    panel do
      field :id, as: :id
      field :organization, as: :belongs_to, disabled: true
      field :enabled, as: :boolean, disabled: true
      field :enforced, as: :boolean, disabled: true
      field :jit_provisioning, as: :boolean, disabled: true
      field :sso_domains, as: :text, disabled: true,
                          format_using: -> { value.ordered.map { |domain| domain.verified? ? domain.domain : "#{domain.domain} (pending)" }.join(", ") }
      field :default_membership_role, as: :text, disabled: true
      field :idp_entity_id, as: :text, disabled: true
      field :idp_sso_url, as: :text, disabled: true
      field :last_login_at, as: :date_time, disabled: true, format: "DDDD, T"

      sidebar do
        field :created_at, as: :date_time, disabled: true, format: "DDDD, T"
        field :updated_at, as: :date_time, disabled: true, format: "DDDD, T"
      end
    end
  end
end
