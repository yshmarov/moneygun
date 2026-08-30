# frozen_string_literal: true

require "application_system_test_case"

class OrganizationCreationSystemTest < ApplicationSystemTestCase
  test "a signed-in user creates an organization" do
    user = users(:unassociated)
    sign_in user

    visit new_organization_path(skip: 1)
    fill_in Organization.human_attribute_name(:name), with: "Acme Studio"
    find("input[type=submit]:not([disabled])").click

    assert_text I18n.t("agreements.acceptances.organization_dpa.title", organization: "Acme Studio")
    organization = Organization.find_by!(name: "Acme Studio")
    assert_current_path organization_dpa_agreement_path(organization)
    check "acceptance_confirmed"
    click_button I18n.t("agreements.acceptances.accept_and_continue")

    assert_text "Acme Studio"
    assert_current_path organization_path(organization)
    assert organization.memberships.active.exists?(user: user, role: "admin")
  end
end
