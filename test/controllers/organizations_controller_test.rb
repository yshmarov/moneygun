require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)

    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get organizations_url
    assert_response :success

    # displays only organizations that the user is a member of
    assert_match @organization.name, response.body
    organization2 = organizations(:two)
    assert_no_match organization2.name, response.body
  end

  test "should get new" do
    get new_organization_url
    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      post organizations_url, params: { organization: { name: @organization.name } }
    end

    assert_redirected_to organization_dashboard_path(Organization.last)
    assert_equal @user, Organization.last.users.first
    assert_equal "admin", @user.memberships.last.role
  end

  test "should show organization" do
    get organization_url(@organization)
    assert_response :success

    # does not show organization if user is not a member
    organization = organizations(:two)
    get organization_url(organization)
    assert_redirected_to root_url
  end

  test "should get edit" do
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch organization_url(@organization),
            params: { organization: { name: @organization.name } },
            headers: { "HTTP_REFERER" => organization_path(@organization) }
    assert_redirected_to organization_url(@organization)
  end

  test "should not update organization he does not belong to" do
    organization = organizations(:two)
    patch organization_url(organization), params: { organization: { name: organization.name } }
    assert_redirected_to root_url
    assert_equal organization.name, organization.reload.name
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should update organization and respect referer from memberships path" do
    memberships_path = organization_memberships_path(@organization)

    patch organization_url(@organization),
          params: { organization: { name: @organization.name } },
          headers: { "HTTP_REFERER" => memberships_path }

    assert_redirected_to memberships_path
    assert_equal I18n.t("organizations.update.success"), flash[:notice]
  end

  test "should handle failed update with memberships referer" do
    memberships_path = organization_memberships_path(@organization)

    # Force validation failure by using empty name
    patch organization_url(@organization),
          params: { organization: { name: "" } },
          headers: { "HTTP_REFERER" => memberships_path }

    assert_redirected_to memberships_path
    assert_equal I18n.t("organizations.update.error"), flash[:alert]
  end

  test "only admin can destroy organization" do
    user = users(:two)
    membership = @organization.memberships.create!(user:, role: Membership.roles[:member])
    sign_in(user)

    assert_no_difference("Organization.count") do
      delete organization_url(@organization)
    end

    membership.update!(role: Membership.roles[:admin])
    assert_difference("Organization.count", -1) do
      delete organization_url(@organization)
    end

    assert_redirected_to organizations_url
  end
end
