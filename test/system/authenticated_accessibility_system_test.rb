# frozen_string_literal: true

require "application_system_test_case"

class AuthenticatedAccessibilitySystemTest < ApplicationSystemTestCase
  setup do
    @organization = organizations(:one)
    sign_in users(:one)
  end

  test "organization dashboard is axe clean" do
    visit organization_dashboard_path(@organization)

    assert_selector "main#main-content"
    assert_axe_clean
  end

  test "members index is axe clean" do
    visit organization_memberships_path(@organization)

    assert_selector "main#main-content"
    assert_axe_clean
  end

  test "audit log is axe clean" do
    visit organization_audit_logs_path(@organization)

    assert_selector "main#main-content"
    assert_axe_clean
  end

  test "data exports index is axe clean" do
    visit organization_data_exports_path(@organization)

    assert_selector "main#main-content"
    assert_axe_clean
  end
end
