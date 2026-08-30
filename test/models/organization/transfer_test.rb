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

  test "transfer candidates exclude the owner and deactivated members" do
    organization = organizations(:one)
    active_membership = organization.memberships.create!(user: users(:two), role: "member")
    deactivated_membership = organization.memberships.create!(user: users(:three), role: "member", deactivated_at: 1.day.ago)

    assert_equal [active_membership], organization.ownership_transfer_candidate_memberships.to_a
    assert_equal [users(:two)], organization.ownership_transfer_candidate_users.to_a
    assert_not_includes organization.ownership_transfer_candidate_memberships, deactivated_membership
  end

  test "non transferable reasons explain when no candidate exists" do
    organization = organizations(:one)

    assert_equal [:no_other_members], organization.non_transferable_reasons
  end

  test "notification failures do not disguise a completed transfer" do
    organization = organizations(:one)
    new_owner = users(:two)
    organization.memberships.create!(user: new_owner, role: "member")
    delivery = mock
    OrganizationMailer.stubs(:ownership_transferred).returns(delivery)
    delivery.stubs(:deliver_later).raises("queue unavailable")

    error = assert_raises(RuntimeError) do
      organization.transfer_ownership(new_owner.id)
    end

    assert_equal "queue unavailable", error.message
    assert_equal new_owner, organization.reload.owner
  end
end
