class Current < ActiveSupport::CurrentAttributes
  # attribute :user, :organization
  attribute :membership, :organizations, :organization
end
