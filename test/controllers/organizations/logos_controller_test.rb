# frozen_string_literal: true

require "test_helper"

class Organizations::LogosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in @user
  end

  test "admin removes organization logo" do
    assert_predicate @organization.logo, :attached?

    delete organization_logo_url(@organization)

    assert_redirected_to edit_organization_url(@organization)
    assert_not @organization.reload.logo.attached?
  end

  test "member cannot remove organization logo" do
    member = users(:unassociated)
    @organization.memberships.create!(user: member, role: :member)
    sign_in member

    delete organization_logo_url(@organization)

    assert_redirected_to organizations_url
    assert_predicate @organization.reload.logo, :attached?
    assert_equal I18n.t("shared.errors.not_authorized"), flash[:alert]
  end
end
