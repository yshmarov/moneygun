# frozen_string_literal: true

require "test_helper"

class MembershipRemovalNotificationTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:three)
    @organization.memberships.find_or_create_by!(user: @organization.owner) { |membership| membership.role = "admin" }
    @user = users(:unassociated)
    @membership = @organization.memberships.create!(user: @user, role: "member")
  end

  test "sends notification when membership is deactivated" do
    assert_difference -> { @user.notifications.count }, 1 do
      @membership.try_destroy
    end

    notification = @user.notifications.last
    assert_equal "Membership::RemovalNotifier::Notification", notification.type
    assert_equal @organization, notification.params[:organization]
  end

  test "does not send notification when membership cannot be deactivated" do
    admin_membership = @organization.memberships.find_by!(user: @organization.owner)

    assert_no_difference -> { admin_membership.user.notifications.count } do
      assert_not admin_membership.try_destroy
    end
  end
end
