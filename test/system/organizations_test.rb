require "application_system_test_case"

class OrganizationsTest < ApplicationSystemTestCase
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in @user
  end

  test "visiting the index" do
    skip
    visit organizations_url
    assert_selector "h1", text: "Organizations"
  end

  test "should create organization" do
    skip
    visit organizations_url
    click_on "New organization"

    fill_in "Name", with: @organization.name
    click_on "Create Organization"

    assert_text "Organization was successfully created"
  end

  test "should update Organization" do
    skip
    visit organization_url(@organization)
    click_on "Edit this organization", match: :first

    fill_in "Name", with: @organization.name
    click_on "Update Organization"

    assert_text "Organization was successfully updated"
  end

  test "should destroy Organization" do
    skip
    visit organization_url(@organization)
    click_on "Destroy this organization", match: :first

    assert_text "Organization was successfully destroyed"
  end
end
