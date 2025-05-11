require "test_helper"

class DiscoversControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    sign_in users(:one)

    get discover_path
    assert_response :success
  end

  test "should not get show if not signed in" do
    get discover_path
    assert_redirected_to new_user_session_path
  end

  test "should see only public and restricted organizations" do
    sign_in users(:one)

    organization1 = Organization.create!(privacy_setting: :public, owner: users(:one), name: "Organization One")
    organization2 = Organization.create!(privacy_setting: :restricted, owner: users(:one), name: "Organization Two")
    organization3 = Organization.create!(privacy_setting: :private, owner: users(:one), name: "Organization Three")

    get discover_path
    assert_response :success
    assert_select "h1", I18n.t("discovers.show.page_title")
    assert_includes response.body, organization1.name
    assert_includes response.body, organization2.name
    assert_not_includes response.body, organization3.name
  end
end
