require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @organization = organizations(:one)
    sign_in @user
  end

  test "#index" do
    MembershipInvitationNotifier.with(organization: @organization).deliver(@user)
    notification = @user.notifications.last
    assert_not notification.seen?

    get notifications_url
    assert_response :success

    notification.reload
    assert notification.seen?
  end
end
