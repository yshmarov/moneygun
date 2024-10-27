require "application_system_test_case"

class MembershipsTest < ApplicationSystemTestCase
  setup do
    @membership = memberships(:one)
    @user = users(:one)
    @organization = organizations(:one)
    sign_in @user
  end

  test "visiting the index" do
    skip
    visit organization_memberships_url(@organization)
    assert_selector "h1", text: "Memberships"
  end

  test "should create membership" do
    skip
    visit organization_memberships_url(@organization)
    click_on "New membership"

    fill_in "Organization", with: @membership.organization_id
    fill_in "Role", with: @membership.role
    fill_in "User", with: @membership.user_id
    click_on "Create Membership"

    assert_text "Membership was successfully created"
    click_on "Back"
  end

  test "should destroy Membership" do
    skip
    visit membership_url(@membership)
    click_on "Destroy this membership", match: :first

    assert_text "Membership was successfully destroyed"
  end
end
