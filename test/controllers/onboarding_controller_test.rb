# frozen_string_literal: true

require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "onboarding@example.com")
    sign_in @user
  end

  test "requires terms and profile before completing onboarding" do
    get organizations_path
    assert_redirected_to user_terms_agreement_path

    version = agreements_versions(:user_terms)
    post accept_user_terms_agreement_path, params: { acceptance: { agreement_version_id: version.id, confirmed: "0" } }
    assert_response :unprocessable_content

    post accept_user_terms_agreement_path, params: { acceptance: { agreement_version_id: version.id, confirmed: "1", marketing_consent: "1" } }
    assert_redirected_to profile_onboarding_path
    assert_predicate @user.reload, :terms_accepted?
    assert_predicate @user, :marketing_consent?

    patch update_profile_onboarding_path, params: { user: { name: "Onboarded User" } }
    assert_redirected_to organizations_path
    assert_predicate @user.reload, :onboarding_completed?
  end
end
