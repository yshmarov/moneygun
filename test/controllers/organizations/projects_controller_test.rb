require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user

    @organization = organizations(:one)
    @project = projects(:one)
  end

  test "should get index" do
    get organization_projects_url(@organization)
    assert_response :success

    get organization_projects_url(organizations(:two))
    assert_redirected_to organizations_url
    assert_match I18n.t("shared.errors.not_authorized"), flash[:alert]

    sign_in users(:two)
    membership = @organization.memberships.create(user: users(:two), role: Membership.roles[:member])
    get organization_projects_url(@organization)
    assert_response :redirect

    membership.update(role: Membership.roles[:admin])
    get organization_projects_url(@organization)
    assert_response :success
  end

  test "should get new" do
    get new_organization_project_url(@organization)
    assert_response :success
  end

  test "should create project" do
    assert_no_difference("Project.count") do
      post organization_projects_url(@organization), params: { project: { organization_id: @organization.id, name: @project.name } }
    end

    assert_difference("Project.count") do
      post organization_projects_url(@organization), params: { project: { organization_id: @organization.id, name: "New name" } }
    end

    assert_redirected_to organization_project_url(@organization, Project.last)
  end

  test "should show project" do
    get organization_project_url(@organization, @project)
    assert_response :success

    get organization_project_url(@organization, projects(:two))
    assert_response :not_found

    get organization_project_url(organizations(:two), projects(:two))
    assert_redirected_to organizations_url
    assert_match I18n.t("shared.errors.not_authorized"), flash[:alert]

    sign_in users(:two)
    membership = @organization.memberships.create(user: users(:two), role: Membership.roles[:member])
    get organization_project_url(@organization, @project)
    assert_response :redirect

    membership.update(role: Membership.roles[:admin])
    get organization_project_url(@organization, @project)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_project_url(@organization, @project)
    assert_response :success
  end

  test "should update project" do
    # admin can update
    assert_changes -> { @project.reload.name } do
      patch organization_project_url(@organization, @project), params: { project: { name: "changed" } }
    end
    assert_response :redirect

    # can't update other organization's project
    project = projects(:two)
    assert_no_changes -> { project.reload.name } do
      patch organization_project_url(organizations(:two), project), params: { project: { name: "changed" } }
    end
    assert_redirected_to organizations_url
    assert_match I18n.t("shared.errors.not_authorized"), flash[:alert]

    # member can't update
    sign_in users(:two)
    @organization.memberships.create(user: users(:two), role: Membership.roles[:member])
    assert_no_changes -> { @project.reload.name } do
      patch organization_project_url(@organization, @project), params: { project: { name: "changed" } }
    end
    assert_response :redirect
    assert_redirected_to root_url
    assert_match I18n.t("shared.errors.not_authorized"), flash[:alert]
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete organization_project_url(@organization, @project)
    end

    assert_redirected_to organization_projects_url(@organization)
  end
end
