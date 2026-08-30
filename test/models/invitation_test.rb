# frozen_string_literal: true

require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  test "normalizes email and generates an expiring token" do
    invitation = organizations(:one).invitations.create!(email: " New@Example.COM ", invited_by: users(:one))

    assert_equal "new@example.com", invitation.email
    assert_predicate invitation.token, :present?
    assert_operator invitation.expires_at, :>, 13.days.from_now
  end

  test "accept creates membership without creating a duplicate user" do
    invitation = invitations(:pending)
    user = users(:unassociated)

    assert_difference -> { Membership.count }, 1 do
      invitation.accept!(actor_user: user)
    end

    assert_predicate invitation, :destroyed?
    assert_predicate invitation.organization.membership_for(user), :active?
  end

  test "accept reactivates historical membership under invited role" do
    invitation = invitations(:pending)
    membership = invitation.organization.memberships.create!(user: users(:unassociated), deactivated_at: 1.day.ago)
    invitation.update!(role: "admin")

    assert_no_difference "Membership.count" do
      invitation.accept!(actor_user: users(:unassociated))
    end

    assert_predicate membership.reload, :active?
    assert_predicate membership, :admin?
  end

  test "another email cannot accept" do
    assert_raises(Invitation::TransitionError) { invitations(:pending).accept!(actor_user: users(:two)) }
  end
end
