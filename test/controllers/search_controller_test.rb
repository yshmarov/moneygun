# frozen_string_literal: true

require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should require authentication" do
    sign_out @user
    get search_path
    assert_redirected_to new_user_session_path
  end

  test "should search organizations correctly" do
    get search_path
    assert_response :success
    assert_select "#organizations", count: 0

    get search_path, params: { search: { query: "open" } }
    assert_response :success
    assert_select "#organizations tr", count: 1
    assert_select "#organizations", text: /OpenAI/
  end
end
