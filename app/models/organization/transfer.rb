module Organization::Transfer
  extend ActiveSupport::Concern

  def transfer_ownership(user_id)
    # previous_owner = owner

    membership = memberships.find_by(user_id: user_id)
    return false unless membership

    new_owner = organization_user.user

    ApplicationRecord.transaction do
      membership.update!(admin: true)
      update!(owner: new_owner)
    end
  rescue => e
    Rails.logger.error("Ownership transfer failed: #{e.message}")
    false
  end

  def owner?(user)
    owner_id == user.id
  end

  # private

  def can_transfer?(user)
    owner?(user) && users.size >= 2
  end
end
