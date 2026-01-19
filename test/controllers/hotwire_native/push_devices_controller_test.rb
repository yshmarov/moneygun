# frozen_string_literal: true

require "test_helper"

class HotwireNative::PushDevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "creates an ApplicationPushDevice for iOS with apple platform" do
    assert_difference "ApplicationPushDevice.count" do
      post hotwire_native_push_devices_path, params: { token: "ios-device-token", platform: "iOS" }
      assert_response :created
    end

    device = ApplicationPushDevice.last
    assert_equal "apple", device.platform
    assert_equal "ios-device-token", device.token
    assert_equal @user, device.owner
  end

  test "creates an ApplicationPushDevice for Android with google platform" do
    assert_difference "ApplicationPushDevice.count" do
      post hotwire_native_push_devices_path, params: { token: "android-device-token", platform: "fcm" }
      assert_response :created
    end

    device = ApplicationPushDevice.last
    assert_equal "google", device.platform
    assert_equal "android-device-token", device.token
    assert_equal @user, device.owner
  end

  test "does not create duplicate devices for same token" do
    post hotwire_native_push_devices_path, params: { token: "same-token", platform: "iOS" }
    assert_response :created

    assert_no_difference "ApplicationPushDevice.count" do
      post hotwire_native_push_devices_path, params: { token: "same-token", platform: "iOS" }
      assert_response :created
    end
  end

  test "deletes an ApplicationPushDevice" do
    @user.push_devices.create!(token: "test", platform: "apple")

    assert_difference "ApplicationPushDevice.count", -1 do
      delete hotwire_native_push_device_path(token: "test")
      assert_response :success
    end
  end

  test "404 deleting a missing token" do
    assert_no_difference "ApplicationPushDevice.count" do
      delete hotwire_native_push_device_path(token: "missing")
      assert_response :not_found
    end
  end
end
