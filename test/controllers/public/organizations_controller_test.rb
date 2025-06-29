require "test_helper"

class Public::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in users(:one)

    get public_organizations_path
    assert_response :success
  end

  test "should not get index if not signed in" do
    get public_organizations_path
    assert_redirected_to new_user_session_path
  end

  test "should see only public and restricted organizations" do
    sign_in users(:one)

    organization1 = Organization.create!(privacy_setting: :public, owner: users(:one), name: "Organization One", logo: active_storage_blobs(:openai_logo_blob))
    organization2 = Organization.create!(privacy_setting: :restricted, owner: users(:one), name: "Organization Two", logo: active_storage_blobs(:apple_logo_blob))
    organization3 = Organization.create!(privacy_setting: :private, owner: users(:one), name: "Organization Three", logo: active_storage_blobs(:google_logo_blob))

    get public_organizations_path
    assert_response :success
    assert_includes response.body, organization1.name
    assert_includes response.body, organization2.name
    assert_not_includes response.body, organization3.name
  end

  test "should get show" do
    sign_in users(:one)

    organization = Organization.create!(privacy_setting: :public, owner: users(:one), name: "Organization One", logo: active_storage_blobs(:openai_logo_blob))

    get public_organization_path(organization)
    assert_response :success

    organization.privacy_setting_private!
    get public_organization_path(organization)
    assert_response :not_found

    organization.privacy_setting_restricted!
    get public_organization_path(organization)
    assert_response :success
  end
end
