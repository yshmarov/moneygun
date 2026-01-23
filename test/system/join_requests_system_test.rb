# frozen_string_literal: true

require "application_system_test_case"

class JoinRequestsSystemTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @organization = organizations(:one)
    # Delete any existing join requests to avoid ambiguous matches
    JoinRequest.where(organization: @organization).destroy_all
  end

  test "user can request to join a restricted organization" do
    # Create a new user for this test
    requesting_user = User.create!(email: "requester@example.com", password: "password123", confirmed_at: Time.current)

    # Make organization restricted and add logo (required for discoverability)
    @organization.update!(privacy_setting: :restricted)
    @organization.logo.attach(io: Rails.root.join("test/fixtures/files/superails-logo.png").open, filename: "logo.png")

    sign_in requesting_user

    visit public_organizations_path

    # Should see the organization
    assert_text @organization.name

    # Click on the organization row to see details
    find("tr", text: @organization.name).click

    # Request to join
    click_button I18n.t("public.organizations.show.actions.request_to_join")

    # Should show success message
    assert_text I18n.t("join_requests.success.access_requested")

    # Should have a pending join request
    assert @organization.received_join_requests.pending.exists?(user: requesting_user)
  end

  test "user can cancel their pending join request" do
    # Create a new user and join request for this test
    requesting_user = User.create!(email: "cancel_requester@example.com", password: "password123", confirmed_at: Time.current)

    # Make organization restricted and add logo
    @organization.update!(privacy_setting: :restricted)
    @organization.logo.attach(io: Rails.root.join("test/fixtures/files/superails-logo.png").open, filename: "logo.png")

    # Create a join request
    join_request = @organization.received_join_requests.create!(user: requesting_user)

    sign_in requesting_user

    visit user_organizations_sent_join_requests_path

    # Should see the organization in pending requests
    assert_text @organization.name

    # Cancel the request
    accept_confirm do
      click_button I18n.t("public.organizations.show.actions.cancel_request")
    end

    # Should show success message
    assert_text I18n.t("users.organizations.sent_join_requests.destroy.success")

    # Join request should be destroyed
    assert_not JoinRequest.exists?(join_request.id)
  end

  test "admin can approve a join request" do
    # Use a new user to avoid fixture conflicts
    requesting_user = User.create!(email: "approve_me@example.com", password: "password123", confirmed_at: Time.current)

    # Make organization restricted
    @organization.update!(privacy_setting: :restricted)

    # Create a join request
    join_request = @organization.received_join_requests.create!(user: requesting_user)

    sign_in @admin

    visit organization_received_join_requests_path(@organization)

    # Should see the join request
    assert_text requesting_user.email

    # Approve the request - use within to scope to the specific row
    within("tr", text: requesting_user.email) do
      click_button I18n.t("join_requests.buttons.approve")
    end

    # Should show success message
    assert_text I18n.t("join_requests.approve.success")

    # User should now be a member
    assert @organization.reload.participant?(requesting_user)

    # Join request should be approved
    assert_equal "approved", join_request.reload.status
  end

  test "admin can reject a join request" do
    # Use a new user to avoid fixture conflicts
    requesting_user = User.create!(email: "reject_me@example.com", password: "password123", confirmed_at: Time.current)

    # Make organization restricted
    @organization.update!(privacy_setting: :restricted)

    # Create a join request
    join_request = @organization.received_join_requests.create!(user: requesting_user)

    sign_in @admin

    visit organization_received_join_requests_path(@organization)

    # Should see the join request
    assert_text requesting_user.email

    # Reject the request - use within to scope to the specific row
    within("tr", text: requesting_user.email) do
      click_button I18n.t("join_requests.buttons.reject")
    end

    # Should show success message
    assert_text I18n.t("join_requests.reject.success")

    # User should not be a member
    assert_not @organization.reload.participant?(requesting_user)

    # Join request should be destroyed
    assert_not JoinRequest.exists?(join_request.id)
  end

  test "user can directly join a public organization" do
    # Create a new user for this test
    joining_user = User.create!(email: "joiner@example.com", password: "password123", confirmed_at: Time.current)

    # Make organization public and add logo
    @organization.update!(privacy_setting: :public)
    @organization.logo.attach(io: Rails.root.join("test/fixtures/files/superails-logo.png").open, filename: "logo.png")

    sign_in joining_user

    visit public_organizations_path

    # Should see the organization
    assert_text @organization.name

    # Click on the organization row
    find("tr", text: @organization.name).click

    # Join directly
    click_button I18n.t("public.organizations.show.actions.join")

    # Should show success message
    assert_text I18n.t("join_requests.success.access_granted")

    # User should now be a member
    assert @organization.reload.participant?(joining_user)
  end

  test "join requests tab only shows for restricted organizations" do
    sign_in @admin

    # For private organization, join requests tab should not be visible
    @organization.update!(privacy_setting: :private)
    visit organization_memberships_path(@organization)
    assert_no_text I18n.t("join_requests.index.title")

    # For restricted organization, join requests tab should be visible
    @organization.update!(privacy_setting: :restricted)
    visit organization_memberships_path(@organization)
    assert_text I18n.t("join_requests.index.title")
  end
end
