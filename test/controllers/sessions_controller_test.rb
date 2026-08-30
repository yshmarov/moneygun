# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new session reloads the full page when reached from a turbo frame" do
    get new_session_path, headers: { "Turbo-Frame" => "modal" }

    assert_response :success
    assert_select "meta[name='turbo-visit-control'][content='reload']"
  end

  test "sign-in form prefills the remembered email unless a parameter overrides it" do
    cookies[:remembered_email] = encrypt_cookie_value(:remembered_email, "remembered@example.com")

    get new_session_path
    assert_includes response.body, 'value="remembered@example.com"'
    assert_select "meta[name='turbo-visit-control'][content='reload']", count: 0

    get new_session_path(email_address: "explicit@example.com")
    assert_includes response.body, 'value="explicit@example.com"'
  end

  test "existing user receives a magic link without an authenticated session" do
    user = users(:one)

    assert_difference "MagicLink.count", 1 do
      post session_path, params: { email_address: user.email }
    end

    assert_redirected_to session_magic_link_path
    assert_predicate cookies[:pending_authentication_token], :present?
    assert_nil cookies[:session_token]
  end

  test "valid new email creates an unverified user" do
    assert_difference ["User.count", "MagicLink.count"], 1 do
      post session_path, params: { email_address: "new@example.com" }
    end

    assert_not_predicate User.find_by!(email: "new@example.com"), :email_verified?
  end

  test "invalid email follows the same redirect without creating a record" do
    assert_no_difference ["User.count", "MagicLink.count"] do
      post session_path, params: { email_address: "not-an-email" }
    end

    assert_redirected_to session_magic_link_path
  end
end
