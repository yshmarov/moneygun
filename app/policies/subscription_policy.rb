# frozen_string_literal: true

class SubscriptionPolicy < Organization::BasePolicy
  # All actions require admin (inherited from Organization::BasePolicy)
  # - index?, show?, create?, update?, destroy? all default to membership.admin?

  def checkout?
    membership.admin?
  end

  def success?
    membership.admin?
  end

  def billing_portal?
    membership.admin?
  end
end
