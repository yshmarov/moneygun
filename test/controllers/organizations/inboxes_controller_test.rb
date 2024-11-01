require "test_helper"

class InboxesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user

    @organization = organizations(:one)
    @inbox = inboxes(:one)
  end

  test "should get index" do
    assert_authorized_to(:index?, @organization, with: InboxPolicy) do
      get organization_inboxes_url(@organization)
      assert_response :success
    end

    get organization_inboxes_url(organizations(:two))
    assert_response :not_found

    sign_in users(:two)
    @organization.memberships.create(user: users(:two), role: Membership.roles[:member])
    get organization_inboxes_url(@organization)
    assert_response :redirect
  end

  test "should get new" do
    get new_organization_inbox_url(@organization)
    assert_response :success
  end

  test "should create inbox" do
    assert_no_difference("Inbox.count") do
      post organization_inboxes_url(@organization), params: { inbox: { organization_id: @organization.id, name: @inbox.name } }
    end

    assert_difference("Inbox.count") do
      post organization_inboxes_url(@organization), params: { inbox: { organization_id: @organization.id, name: "New name" } }
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
    # admin can update
    assert_authorized_to(:update?, @inbox, with: InboxPolicy) do
      assert_changes -> { @inbox.reload.name } do
      patch organization_inbox_url(@organization, @inbox), params: { inbox: { name: "changed" } }
      end
    end
    assert_response :redirect

    # can't update other organization's inbox
    inbox = inboxes(:two)
    assert_no_changes -> { inbox.reload.name } do
      patch organization_inbox_url(organizations(:two), inbox), params: { inbox: { name: "changed" } }
    end
    assert_response :not_found

    # member can't update
    sign_in users(:two)
    @organization.memberships.create(user: users(:two), role: Membership.roles[:member])
    assert_no_changes -> { @inbox.reload.name } do
      patch organization_inbox_url(@organization, @inbox), params: { inbox: { name: "changed" } }
    end
    assert_response :redirect
    assert_redirected_to root_url
    assert_match "You are not authorized to perform this action.", flash[:alert]
  end

  test "should destroy inbox" do
    assert_difference("Inbox.count", -1) do
      delete organization_inbox_url(@organization, @inbox)
    end

    assert_redirected_to organization_inboxes_url(@organization)
  end
end
