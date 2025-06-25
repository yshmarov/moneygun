require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @organization = organizations(:one)
    sign_in @user
  end

  test "#index" do
    get notifications_url
    assert_response :success
  end

  test "#show marks notification as seen" do
    MembershipInvitationNotifier.with(organization: @organization).deliver(@user)
    notification = @user.notifications.last
    assert_not notification.seen?

    get notification_path(notification)
    assert_redirected_to notifications_url
    notification.reload
    assert notification.seen?

    get notification_path(notification), headers: { "Turbo-Frame": "foo" }
    assert_response :success
  end
end
