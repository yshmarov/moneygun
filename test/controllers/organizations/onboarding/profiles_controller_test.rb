# frozen_string_literal: true

require "test_helper"

class Organizations::Onboarding::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    sign_in users(:one)
  end

  test "shows the organization profile step" do
    get organization_onboarding_profile_url(@organization)

    assert_response :success
    assert_select "form input#organization_name"
  end

  test "updates the organization and advances" do
    patch organization_onboarding_profile_url(@organization), params: { organization: { name: "Acme", website: "https://acme.test" } }

    assert_redirected_to organization_onboarding_team_url(@organization)
    assert @organization.reload.onboarding_step_completed?(:profile)
  end
end
