# frozen_string_literal: true

require "application_system_test_case"

class AuthSystemTest < ApplicationSystemTestCase
  test "the sign-in page is axe clean" do
    visit new_session_path

    assert_selector "main#main-content"
    assert_axe_clean
  end

  test "an existing session reaches the organization list" do
    sign_in users(:one)
    visit organizations_path

    assert_text I18n.t("shared.navigation.organizations")
  end

  test "the login form starts the magic-link flow" do
    visit new_session_path
    fill_in User.human_attribute_name(:email), with: users(:one).email
    click_button I18n.t("sessions.new.submit")

    assert_current_path session_magic_link_path
  end
end
