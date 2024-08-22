require "test_helper"

class InboxesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @inbox = inboxes(:one)
  end

  test "should get index" do
    get inboxes_url
    assert_response :success
  end

  test "should get new" do
    get new_inbox_url
    assert_response :success
  end

  test "should create inbox" do
    skip
    assert_difference("Inbox.count") do
      post inboxes_url, params: { inbox: { account_id: @inbox.account_id, name: @inbox.name } }
    end

    assert_redirected_to inbox_url(Inbox.last)
  end

  test "should show inbox" do
    get inbox_url(@inbox)
    assert_response :success
  end

  test "should get edit" do
    get edit_inbox_url(@inbox)
    assert_response :success
  end

  test "should update inbox" do
    patch inbox_url(@inbox), params: { inbox: { account_id: @inbox.account_id, name: @inbox.name } }
    assert_redirected_to inbox_url(@inbox)
  end

  test "should destroy inbox" do
    assert_difference("Inbox.count", -1) do
      delete inbox_url(@inbox)
    end

    assert_redirected_to inboxes_url
  end
end
