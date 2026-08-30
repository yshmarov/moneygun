# frozen_string_literal: true

class SameOrganizationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    expected = record.organization_id
    return if expected.nil? || value.organization_id == expected

    record.errors.add(attribute, :same_organization)
  end
end
