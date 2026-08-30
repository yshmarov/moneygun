# frozen_string_literal: true

require "test_helper"

class Organizations::Onboarding::TeamsControllerTest < ActionDispatch::IntegrationTest
  test "shows members and invitation action" do
    organization = organizations(:one)
    sign_in users(:one)

    get organization_onboarding_team_url(organization)

    assert_response :success
    assert_select "a[href=?]", new_organization_invitation_path(organization)
    assert_select "a[href=?]", organization_onboarding_subscription_path(organization)
  end
end
