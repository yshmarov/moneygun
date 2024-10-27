require "test_helper"

class InboxesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user

    @organization = organizations(:one)
    @inbox = inboxes(:one)
  end

  test "should get index" do
    get organization_inboxes_url(@organization)
    assert_response :success
  end

  test "should get new" do
    get new_organization_inbox_url(@organization)
    assert_response :success
  end

  test "should create inbox" do
    ActsAsTenant.current_tenant = @organization

    assert_no_difference("Inbox.count") do
      post organization_inboxes_url(@organization), params: { inbox: { organization_id: @organization.id, name: @inbox.name } }
      ActsAsTenant.current_tenant = @organization
    end

    assert_difference("Inbox.count") do
      post organization_inboxes_url(@organization), params: { inbox: { organization_id: @organization.id, name: "New name" } }
      ActsAsTenant.current_tenant = @organization
    end

    assert_redirected_to organization_inbox_url(@organization, Inbox.last)
  end

  test "should show inbox" do
    get organization_inbox_url(@organization, @inbox)
    assert_response :success

    get organization_inbox_url(@organization, inboxes(:two))
    assert_response :not_found

    get organization_inbox_url(organizations(:two), inboxes(:two))
    assert_response :not_found
  end

  test "should get edit" do
    get edit_organization_inbox_url(@organization, @inbox)
    assert_response :success
  end

  test "should update inbox" do
    patch organization_inbox_url(@organization, @inbox), params: { inbox: { organization_id: @organization.id, name: @inbox.name } }
    assert_redirected_to organization_inbox_url(@organization, @inbox)
  end

  test "should destroy inbox" do
    ActsAsTenant.current_tenant = @organization

    assert_difference("Inbox.count", -1) do
      delete organization_inbox_url(@organization, @inbox)
      ActsAsTenant.current_tenant = @organization
    end

    assert_redirected_to organization_inboxes_url(@organization)
  end
end
