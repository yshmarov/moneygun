# frozen_string_literal: true

class Avo::Resources::ScimConnection < Avo::BaseResource
  self.includes = [:organization]
  self.title = -> { record.organization.name }

  def fields
    panel do
      field :id, as: :id
      field :organization, as: :belongs_to, disabled: true
      field :enabled, as: :boolean, disabled: true
      field :token_last_four, as: :text, disabled: true
      field :default_membership_role, as: :text, disabled: true
      field :last_request_at, as: :date_time, disabled: true, format: "DDDD, T"

      sidebar do
        field :created_at, as: :date_time, disabled: true, format: "DDDD, T"
        field :updated_at, as: :date_time, disabled: true, format: "DDDD, T"
      end
    end
  end
end
