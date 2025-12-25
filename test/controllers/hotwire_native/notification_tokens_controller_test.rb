# frozen_string_literal: true

require "test_helper"

class HotwireNative::NotificationTokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "creates a notification token" do
    assert_difference "NotificationToken.count" do
      post hotwire_native_notification_tokens_path, params: { token: "test", platform: "iOS" }
      assert_response :created
    end
  end

  test "deletes a notification token" do
    @user.notification_tokens.create!(token: "test", platform: "iOS")
    assert_difference "NotificationToken.count", -1 do
      delete hotwire_native_notification_token_path(token: "test")
      assert_response :success
    end
  end

  test "raises error deleting a missing token" do
    assert_no_difference "NotificationToken.count" do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete hotwire_native_notification_token_path(token: "missing")
      end
    end
  end
end
