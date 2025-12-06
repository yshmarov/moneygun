# frozen_string_literal: true

require "test_helper"

class Users::InvitationAcceptancesControllerTest < ActionDispatch::IntegrationTest
  test "should show accept form with valid invitation token" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)

    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)
    assert_response :success
    assert_match invited_user.email, response.body
  end

  test "should redirect to sign in with invalid invitation token" do
    get accept_user_invitation_url(invitation_token: "invalid_token")
    assert_redirected_to new_user_session_url
    assert_equal I18n.t("users.invitation_acceptances.show.invalid_token"), flash[:alert]
  end

  test "should accept invitation and set password" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)
    invitation_token = invited_user.invitation_token

    assert_nil invited_user.invitation_accepted_at
    assert_nil invited_user.confirmed_at
    assert_not_nil invited_user.invitation_token

    patch accept_user_invitation_url(invitation_token:),
          params: { user: { password: "newpassword123", password_confirmation: "newpassword123" } }

    invited_user.reload
    assert_redirected_to user_invitations_url
    assert_equal I18n.t("users.invitation_acceptances.update.success"), flash[:notice]
    assert_not_nil invited_user.invitation_accepted_at
    assert_not_nil invited_user.confirmed_at
    assert_nil invited_user.invitation_token
    follow_redirect!
    assert_equal invited_user, controller.current_user
  end

  test "should not accept invitation with invalid password" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)
    invitation_token = invited_user.invitation_token

    patch accept_user_invitation_url(invitation_token:),
          params: { user: { password: "short", password_confirmation: "short" } }

    assert_response :unprocessable_content
    invited_user.reload
    assert_nil invited_user.invitation_accepted_at
    assert_not_nil invited_user.invitation_token
    assert_nil controller.current_user
  end

  test "should not accept invitation with mismatched passwords" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)
    invitation_token = invited_user.invitation_token

    patch accept_user_invitation_url(invitation_token:),
          params: { user: { password: "password123", password_confirmation: "different123" } }

    assert_response :unprocessable_content
    invited_user.reload
    assert_nil invited_user.invitation_accepted_at
    assert_not_nil invited_user.invitation_token
    assert_nil controller.current_user
  end

  test "should redirect to sign in when accepting with invalid token" do
    patch accept_user_invitation_url(invitation_token: "invalid_token"),
          params: { user: { password: "password123", password_confirmation: "password123" } }

    assert_redirected_to new_user_session_url
    assert_equal I18n.t("users.invitation_acceptances.show.invalid_token"), flash[:alert]
  end
end
