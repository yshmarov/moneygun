# frozen_string_literal: true

require "test_helper"

class OrganizationTransferTest < ActiveSupport::TestCase
  test "transfer_ownership" do
    organization = organizations(:one)
    user = users(:two)

    assert_not organization.transfer_ownership(user.id)
    assert_not organization.owner?(user)

    membership = organization.memberships.create!(user: user, role: Membership.roles[:member])
    assert organization.transfer_ownership(user.id)
    assert organization.owner?(user)
    assert membership.reload.admin?
  end
end
