require "test_helper"

class MembershipInvitationTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers
  include Rails.application.routes.mounted_helpers

  setup do
    @organization = organizations(:one)
    @first_admin_membership = @organization.memberships.admin.first
  end

  test "valid membership invitation with correct attributes creates an access request" do
    invitation = MembershipInvitation.new(
      email: "newuser@example.com",
      organization: @organization,
      inviter: @first_admin_membership.user,
      role: Membership.roles[:member]
    )
    assert invitation.valid?
    assert_difference -> { User.count }, 1 do
      assert_difference -> { AccessRequest::InviteToOrganization.count }, 1 do
        assert invitation.save
      end
    end

    user = User.find_by(email: "newuser@example.com")
    assert user.present?
    assert_equal "newuser@example.com", @organization.user_invitations.last.user.email
  end

  test "invalid with incorrect email format" do
    invitation = MembershipInvitation.new(
      email: "invalid-email",
      organization: @organization,
      inviter: @first_admin_membership.user,
      role: "member"
    )
    assert_not invitation.valid?
    assert_includes invitation.errors.messages[:email], "is invalid"
  end

  test "invalid without role" do
    invitation = MembershipInvitation.new(
      email: "newuser@example.com",
      organization: @organization,
      inviter: @first_admin_membership.user
    )
    assert_not invitation.valid?
    assert_includes invitation.errors.messages[:role], "can't be blank"
  end

  test "invalid with non-existent role" do
    invitation = MembershipInvitation.new(
      email: "newuser@example.com",
      organization: @organization,
      inviter: @first_admin_membership.user,
      role: "non_existent_role"
    )
    assert_not invitation.valid?
    assert_includes invitation.errors.messages[:role], "is not included in the list"
    assert_not invitation.save
  end

  test "fails when user is already a member" do
    existing_user = users(:two)
    @organization.memberships.create(user: existing_user, role: "member")

    invitation = MembershipInvitation.new(
      email: existing_user.email,
      organization: @organization,
      inviter: @first_admin_membership.user,
      role: "member"
    )
    assert_not invitation.save
    assert_includes invitation.errors.messages[:base], "#{existing_user.email} is already a member of this organization."
  end
end
