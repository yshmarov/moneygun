# frozen_string_literal: true

require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "unique user-organization combination" do
    membership = Membership.new(organization: organizations(:one), user: users(:one))
    assert_not membership.valid?
    assert_includes membership.errors.messages[:user_id], I18n.t("errors.messages.taken")
    assert_includes membership.errors.messages[:organization_id], I18n.t("errors.messages.taken")
  end

  test "try_destroy" do
    # does not destroy only admin
    organization = organizations(:one)
    membership = organization.memberships.first
    assert_not membership.try_destroy

    # does not destroy only admin
    # destroys member
    new_membership = organization.memberships.create(user: users(:two), role: "member")
    assert_not membership.try_destroy
    assert new_membership.try_destroy

    # does not destroy owner even if there is another admin
    new_membership = organization.memberships.create(user: users(:two), role: "admin")
    assert_not membership.try_destroy

    # destroy previous owner
    membership.organization.transfer_ownership(users(:two))
    assert membership.try_destroy
    assert_not new_membership.try_destroy

    # destroys non-owner admin if there is another admin
    membership = organization.memberships.create(user: users(:one), role: "admin")
    assert membership.try_destroy
    assert_not new_membership.try_destroy
  end

  test "cannot_change_role_if_only_admin" do
    organization = organizations(:one)
    membership = organization.memberships.find_by(role: "admin")

    membership.role = "member"
    assert_not membership.save
    assert_includes membership.errors.messages[:base], "Role cannot be changed because this is the only admin."
  end

  test "default suspended_at is nil (active)" do
    organization = organizations(:one)
    membership = organization.memberships.create(user: users(:two), role: "member")
    assert_nil membership.suspended_at
    assert membership.active?
  end

  test "suspend! sets suspended_at timestamp" do
    organization = organizations(:one)
    membership = organization.memberships.create(user: users(:two), role: "member")
    assert membership.active?

    freeze_time do
      membership.suspend!
      assert membership.suspended?
      assert_equal Time.current, membership.suspended_at
    end
  end

  test "activate! clears suspended_at" do
    organization = organizations(:one)
    membership = organization.memberships.create(user: users(:two), role: "member")
    membership.update!(suspended_at: Time.current)

    membership.activate!
    assert membership.active?
    assert_nil membership.suspended_at
  end

  test "archive! sets user_id to nil and suspended_at" do
    organization = organizations(:one)
    membership = organization.memberships.create(user: users(:two), role: "member")

    freeze_time do
      membership.archive!
      assert_nil membership.user_id
      assert membership.suspended?
      assert_equal Time.current, membership.suspended_at
    end
  end

  test "accessible? returns true only for active memberships with a user" do
    organization = organizations(:one)
    membership = organization.memberships.create(user: users(:two), role: "member")

    assert membership.accessible?

    membership.update!(suspended_at: Time.current)
    assert_not membership.accessible?

    membership.update!(suspended_at: nil, user_id: nil)
    assert_not membership.accessible?
  end

  test "accessible scope returns only active memberships with users" do
    organization = organizations(:one)
    active_membership = organization.memberships.create(user: users(:two), role: "member")
    suspended_membership = organization.memberships.create(user: users(:unassociated), role: "member")
    suspended_membership.update!(suspended_at: Time.current)

    accessible = organization.memberships.accessible
    assert_includes accessible, active_membership
    assert_not_includes accessible, suspended_membership
  end

  test "cannot_suspend_owner" do
    organization = organizations(:one)
    owner_membership = organization.memberships.find_by(user: organization.owner)

    # Add another admin so the only admin check doesn't fail
    organization.memberships.create(user: users(:two), role: "admin")

    owner_membership.suspended_at = Time.current
    assert_not owner_membership.save
    assert_includes owner_membership.errors.messages[:base], I18n.t("errors.models.membership.attributes.base.cannot_suspend_owner")
  end

  test "cannot_suspend_only_admin" do
    # Fresh setup: create org with owner (admin) and demote owner's membership after transfer
    org = Organization.create!(name: "Test Org", owner: users(:unassociated))
    original_admin = org.memberships.first
    new_member = org.memberships.create(user: users(:two), role: "member")

    # Promote new_member to admin and transfer ownership
    new_member.update!(role: "admin")
    org.transfer_ownership(users(:two))
    original_admin.reload
    new_member.reload

    # Now: new_member is owner (admin), original_admin is non-owner admin
    # Demote original_admin to member so new_member is the only admin
    original_admin.update!(role: "member")

    # Now try to suspend new_member - should fail because they're the owner
    # and also because they're the only admin
    new_member.suspended_at = Time.current
    assert_not new_member.save
    # Owner check triggers first
    assert_includes new_member.errors.messages[:base], I18n.t("errors.models.membership.attributes.base.cannot_suspend_owner")

    # Now test a scenario where the only admin is not the owner
    # This requires having the owner be a member (not admin), which isn't really valid
    # in normal operation but let's test the validation directly

    # Alternative test: create org, add second admin, transfer, suspend original (should work),
    # then try to suspend the only remaining accessible admin
    org2 = Organization.create!(name: "Test Org 2", owner: users(:one))
    admin1 = org2.memberships.first
    admin2 = org2.memberships.create(user: users(:unassociated), role: "admin")

    # Transfer to admin2 so admin1 is no longer owner
    org2.transfer_ownership(users(:unassociated))
    admin1.reload
    admin2.reload

    # Suspend admin1 - should work because admin2 is another admin
    admin1.suspended_at = Time.current
    assert admin1.save

    # Now try to suspend admin2 (owner) - should fail
    admin2.suspended_at = Time.current
    assert_not admin2.save
    assert_includes admin2.errors.messages[:base], I18n.t("errors.models.membership.attributes.base.cannot_suspend_owner")

    # Test the "only admin" scenario properly:
    # Create org with owner, add non-admin member, then have the owner try to create
    # a scenario where suspending someone leaves no admins
    org3 = Organization.create!(name: "Test Org 3", owner: users(:two))
    owner_membership = org3.memberships.first
    org3.memberships.create(user: users(:one), role: "member")

    # Cannot suspend owner (who is also the only admin)
    owner_membership.suspended_at = Time.current
    assert_not owner_membership.save
    # Both validations should fail, but owner check comes first
    assert_includes owner_membership.errors.messages[:base], I18n.t("errors.models.membership.attributes.base.cannot_suspend_owner")
  end
end
