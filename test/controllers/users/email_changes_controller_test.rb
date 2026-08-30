# frozen_string_literal: true

require "test_helper"

class Users::EmailChangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "new requires recent authentication" do
    get new_user_email_change_path
    assert_redirected_to new_sudo_path
  end

  test "valid new email sends a scoped code" do
    authenticate_sudo(@user)

    assert_difference "MagicLink.for_email_change.count", 1 do
      post user_email_change_path, params: { email: "newemail@example.com" }
    end

    assert_redirected_to user_email_change_path
    assert_equal "newemail@example.com", MagicLink.last.new_email
  end

  test "valid code updates email and revokes other sessions" do
    other_session = @user.sessions.create!(user_agent: "other", ip_address: "10.0.0.1")
    magic_link = @user.send_magic_link(for: :email_change, new_email: "newemail@example.com")
    verifier = Rails.application.message_verifier(:pending_email_change)
    cookies[:pending_email_change_token] = encrypt_cookie_value(
      :pending_email_change_token,
      verifier.generate(magic_link.new_email, expires_at: magic_link.expires_at)
    )

    patch user_email_change_path, params: { code: magic_link.code }

    assert_redirected_to user_path
    assert_equal "newemail@example.com", @user.reload.email
    assert_not Session.exists?(other_session.id)
  end

  test "sign-in code cannot confirm an email change" do
    sign_in_link = @user.magic_links.create!(purpose: :sign_in)
    email_change_link = @user.send_magic_link(for: :email_change, new_email: "newemail@example.com")
    verifier = Rails.application.message_verifier(:pending_email_change)
    cookies[:pending_email_change_token] = encrypt_cookie_value(
      :pending_email_change_token,
      verifier.generate(email_change_link.new_email, expires_at: email_change_link.expires_at)
    )

    patch user_email_change_path, params: { code: sign_in_link.code }

    assert_redirected_to user_email_change_path
    assert MagicLink.exists?(sign_in_link.id)
    assert_not_equal "newemail@example.com", @user.reload.email
  end
end
