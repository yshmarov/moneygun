# frozen_string_literal: true

require "test_helper"

class Users::ReferralsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "get #index" do
    assert_difference "Refer::ReferralCode.count" do
      get user_referrals_url
      assert_response :success
    end

    assert_no_difference "Refer::ReferralCode.count" do
      get user_referrals_url
      assert_response :success
    end
  end
end
