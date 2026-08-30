# frozen_string_literal: true

module Membership::ScimProvisionable
  extend ActiveSupport::Concern

  class_methods do
    def scim_resource_type = Scimitar::Resources::User

    def scim_attributes_map
      {
        id: :id,
        externalId: :scim_external_id,
        userName: :scim_username,
        name: { formatted: :scim_display_name },
        displayName: :scim_display_name,
        emails: [{ match: "primary", with: true, using: { value: :scim_username, type: "work", primary: true } }],
        active: :scim_active
      }
    end

    def scim_mutable_attributes = nil

    def scim_queryable_attributes
      {
        "id" => { column: :id },
        "externalId" => { column: :scim_external_id },
        "userName" => { column: User.arel_table[:email] },
        "emails" => { column: User.arel_table[:email] },
        "emails.value" => { column: User.arel_table[:email] },
        "active" => { ignore: true }
      }
    end

    def scim_timestamps_map = { created: :created_at, lastModified: :updated_at }
  end

  included do
    include Scimitar::Resources::Mixin
  end

  def scim_username = user&.email

  def scim_username=(value)
    return if value.blank? || user.present?

    normalized = value.to_s.strip.downcase
    self.user = User.find_by(email: normalized) || User.new(email: normalized)
  end

  def scim_display_name = display_name

  def scim_display_name=(value)
    return if value.blank?

    self.display_name = value
    user.name = value if user&.new_record?
  end

  def scim_active = active?

  def scim_active=(value)
    return if value.nil?

    if ActiveModel::Type::Boolean.new.cast(value)
      self.deactivated_at = nil
    elsif active?
      self.deactivated_at = Time.current
    end
  end
end
