# frozen_string_literal: true

require "test_helper"

class MembershipRemovalNotificationTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:three)
    @user = users(:unassociated)
    @membership = @organization.memberships.create!(user: @user, role: "member")
  end

  test "sends notification when membership is destroyed" do
    assert_difference -> { @user.notifications.count }, 1 do
      @membership.destroy
    end

    notification = @user.notifications.last
    assert_equal "Membership::RemovalNotifier::Notification", notification.type
    assert_equal @organization, notification.params[:organization]
  end

  test "does not send notification when membership is not destroyed" do
    # Create a membership that cannot be destroyed (only admin)
    admin_membership = @organization.memberships.create!(user: users(:one), role: "admin")

    # Make it the only admin
    @organization.memberships.where(role: "admin").where.not(id: admin_membership.id).destroy_all

    assert_no_difference -> { admin_membership.user.notifications.count } do
      admin_membership.try_destroy
    end
  end
end
