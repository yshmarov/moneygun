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
end
