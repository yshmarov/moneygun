require "test_helper"

class InboxesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user

    @account = accounts(:one)
    @inbox = inboxes(:one)
  end

  test "should get index" do
    get account_inboxes_url(@account)
    assert_response :success
  end

  test "should get new" do
    get new_account_inbox_url(@account)
    assert_response :success
  end

  test "should create inbox" do
    assert_no_difference("Inbox.count") do
      post account_inboxes_url(@account), params: { inbox: { account_id: @account.id, name: @inbox.name } }
    end

    assert_difference("Inbox.count") do
      post account_inboxes_url(@account), params: { inbox: { account_id: @account.id, name: "New name" } }
    end

    assert_redirected_to account_inbox_url(@account, Inbox.last)
  end

  test "should show inbox" do
    get account_inbox_url(@account, @inbox)
    assert_response :success

    get account_inbox_url(@account, inboxes(:two))
    assert_response :not_found

    get account_inbox_url(accounts(:two), inboxes(:two))
    assert_response :not_found
  end

  test "should get edit" do
    get edit_account_inbox_url(@account, @inbox)
    assert_response :success
  end

  test "should update inbox" do
    patch account_inbox_url(@account, @inbox), params: { inbox: { account_id: @account.id, name: @inbox.name } }
    assert_redirected_to account_inbox_url(@account, @inbox)
  end

  test "should destroy inbox" do
    assert_difference("Inbox.count", -1) do
      delete account_inbox_url(@account, @inbox)
    end

    assert_redirected_to account_inboxes_url(@account)
  end
end
