# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  # attribute :user, :organization
  attribute :membership, :organizations, :organization
end
