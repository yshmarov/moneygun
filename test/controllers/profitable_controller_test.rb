require 'test_helper'

class ProfitableControllerTest < ActionDispatch::IntegrationTest
  test 'only admins can access' do
    get '/profitable'
    assert_redirected_to '/users/sign_in'

    user = users(:two)
    sign_in user
    get '/profitable'
    assert_response :not_found

    user.update!(admin: true)
    sign_in user
    get '/profitable'
    assert_response :success
  end
end
