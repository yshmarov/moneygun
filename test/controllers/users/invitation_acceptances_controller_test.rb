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
    assert_equal I18n.t("users.invitation_acceptances.new.invalid_token"), flash[:alert]
  end

  test "should accept invitation and set password" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)

    assert_nil invited_user.invitation_accepted_at
    assert_nil invited_user.confirmed_at
    assert_not_nil invited_user.invitation_token

    # GET request stores token in session
    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)
    # POST request uses session token
    post accept_user_invitation_create_path,
         params: { user: { password: "newpassword123", password_confirmation: "newpassword123" } }

    invited_user.reload
    assert_redirected_to user_organizations_invitations_url
    assert_equal I18n.t("users.invitation_acceptances.create.success"), flash[:notice]
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

    # GET request stores token in session
    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)
    # POST request uses session token
    post accept_user_invitation_create_path,
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

    # GET request stores token in session
    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)
    # POST request uses session token
    post accept_user_invitation_create_path,
         params: { user: { password: "password123", password_confirmation: "different123" } }

    assert_response :unprocessable_content
    invited_user.reload
    assert_nil invited_user.invitation_accepted_at
    assert_not_nil invited_user.invitation_token
    assert_nil controller.current_user
  end

  test "should redirect to sign in when accepting with invalid token" do
    post accept_user_invitation_create_path,
         params: { user: { password: "password123", password_confirmation: "password123" } }

    assert_redirected_to new_user_session_url
    assert_equal I18n.t("users.invitation_acceptances.new.invalid_token"), flash[:alert]
  end

  test "should redirect if invitation already accepted" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)
    invited_user.update!(invitation_accepted_at: Time.current)

    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)
    assert_redirected_to new_user_session_url
    assert_equal I18n.t("users.invitation_acceptances.new.invalid_token"), flash[:alert]
  end

  test "should redirect if token expired" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)
    invited_user.update!(invitation_created_at: 8.days.ago)

    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)
    assert_redirected_to new_user_session_url
    assert_equal I18n.t("users.invitation_acceptances.new.invalid_token"), flash[:alert]
  end

  test "should not accept already accepted invitation" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)
    invited_user.update!(invitation_accepted_at: Time.current)

    # GET request should redirect since invitation already accepted
    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)
    assert_redirected_to new_user_session_url
    assert_equal I18n.t("users.invitation_acceptances.new.invalid_token"), flash[:alert]
  end

  test "should prevent race condition with database lock" do
    inviter = users(:one)
    organization = organizations(:one)
    invited_user = User.invite!({ email: "invited@example.com" }, inviter)
    organization.user_invitations.create!(user: invited_user)

    # GET request stores token in session
    get accept_user_invitation_url(invitation_token: invited_user.invitation_token)

    # Simulate concurrent request by accepting invitation between GET and POST
    invited_user.update!(invitation_accepted_at: Time.current, invitation_token: nil)

    # POST request should be rejected even if it passes initial validation
    post accept_user_invitation_create_path,
         params: { user: { password: "newpassword123", password_confirmation: "newpassword123" } }

    assert_redirected_to new_user_session_url
    assert_equal I18n.t("users.invitation_acceptances.new.invalid_token"), flash[:alert]
  end
end
