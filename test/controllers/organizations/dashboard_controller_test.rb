# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in users(:one)
    get organization_dashboard_url(organizations(:one))
    assert_response :success
  end

  test "only subscribed users can access the paywalled page" do
    user = users(:one)
    organization = organizations(:one)
    sign_in user
    get organization_paywalled_page_url(organization)
    assert_redirected_to organization_subscriptions_url(organization)
    assert_equal I18n.t("shared.errors.not_subscribed"), flash[:alert]

    organization.set_payment_processor :fake_processor, allow_fake: true
    organization.payment_processor.subscribe(plan: "fake")
    get organization_paywalled_page_url(organization)
    assert_response :success
  end
end
