require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get search index" do
    get search_path
    assert_response :success
  end

  test "should require authentication" do
    sign_out @user
    get search_path
    assert_redirected_to new_user_session_path
  end

  test "should search organizations by name case insensitive" do
    get search_path, params: { query: "penai" }
    assert_response :success
    assert_match "OpenAI", response.body
  end
end
