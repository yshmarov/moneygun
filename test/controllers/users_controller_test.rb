# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should redirect to sign in when not authenticated" do
    get user_url
    assert_redirected_to new_session_url
  end

  test "should get show when authenticated" do
    sign_in @user
    get user_url
    assert_response :success
  end

  test "destroy deletes an account without retained history" do
    user = User.create!(email: "controller-erasable@example.com", email_verified_at: Time.current, onboarding_completed_at: Time.current)
    accept_agreement "user_terms", subject: user
    sign_in user
    authenticate_sudo user

    assert_difference "User.count", -1 do
      delete user_url
    end

    assert_redirected_to new_session_url
  end

  test "destroy redacts an account with retained history" do
    user = User.create!(email: "controller-retained@example.com", name: "Retained Controller User", email_verified_at: Time.current, onboarding_completed_at: Time.current)
    accept_agreement "user_terms", subject: user
    membership = organizations(:one).memberships.create!(user: user, role: "member")
    AuditLog.log!(organization: membership.organization, actor: membership, action: "project.reviewed", actor_kind: "member")
    sign_in user
    authenticate_sudo user

    assert_no_difference "User.count" do
      delete user_url
    end

    assert_redirected_to new_session_url
    assert_predicate user.reload, :redacted?
    assert_predicate membership.reload, :deactivated?
  end

  test "destroy explains why account closure is blocked" do
    sign_in @user
    authenticate_sudo @user

    assert_no_difference "User.count" do
      delete user_url
    end

    assert_redirected_to user_url
    assert_equal I18n.t("users.security.delete_account_disabled.owns_organizations"), flash[:alert]
  end
end
