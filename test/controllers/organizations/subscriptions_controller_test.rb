require "test_helper"

class Organizations::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in @user
  end

  test "#index" do
    get organization_subscriptions_url(@organization)
    assert_response :success
  end

  test "#checkout" do
    skip "will work if you have valid stripe API keys"
    get organization_subscriptions_checkout_path(@organization, price_id: "price_1NmG52GHcaLYld8Ifu7SVe6y")
    assert_match %r{\Ahttps://checkout.stripe.com/c/pay/cs_test_}, response.redirect_url
  end
end
