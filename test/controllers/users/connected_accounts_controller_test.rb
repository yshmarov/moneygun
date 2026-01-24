# frozen_string_literal: true

require "test_helper"

class Users::ConnectedAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "get #index" do
    get user_connected_accounts_url
    assert_response :success
  end
end
