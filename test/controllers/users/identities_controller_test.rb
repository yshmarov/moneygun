# frozen_string_literal: true

require "test_helper"

class Users::IdentitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "get #index" do
    get user_identities_url
    assert_response :success
  end
end
