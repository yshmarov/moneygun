require 'test_helper'

class Users::MembershipRequestsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    user = users(:one)
    sign_in user

    get user_membership_requests_url
    assert_response :success
  end

  test 'should create membership for public organization' do
    membership = memberships(:one)
    user = membership.user
    requested_organization = organizations(:three)
    requested_organization.privacy_setting_public!

    sign_in user

    assert_difference 'Membership.count', 1 do
      post user_membership_requests_url(organization_id: requested_organization.id)
    end

    assert_response :redirect
    assert_equal I18n.t('membership_requests.success.access_granted'), flash[:notice]
  end

  test 'should create membership request for restricted organization' do
    membership = memberships(:one)
    user = membership.user
    requested_organization = organizations(:three)
    requested_organization.privacy_setting_restricted!

    sign_in user

    assert_difference 'AccessRequest::UserRequestForOrganization.count', 1 do
      post user_membership_requests_url(organization_id: requested_organization.id)
    end

    assert_response :redirect
    assert_equal I18n.t('membership_requests.success.access_requested'), flash[:notice]
  end

  test 'should not create membership request if request params are not valid' do
    membership = memberships(:one)
    user = membership.user
    requested_organization = organizations(:one)

    sign_in user

    assert_no_difference 'AccessRequest::UserRequestForOrganization.count' do
      assert_no_difference 'Membership.count' do
        post user_membership_requests_url(organization_id: requested_organization.id)
      end
    end

    assert_response :redirect
    assert_equal I18n.t('membership_requests.errors.already_participant'), flash[:alert]
  end

  test 'should catch error if organization is not found' do
    membership = memberships(:one)
    user = membership.user
    organization_id = 'invalid'

    sign_in user

    post user_membership_requests_url(organization_id:)

    assert_redirected_to public_organizations_path
    assert_equal I18n.t('organizations.errors.not_found'), flash[:alert]
  end

  test 'destroy' do
    user = users(:one)
    sign_in user

    organization = organizations(:three)
    organization.privacy_setting_restricted!

    assert_equal 0, user.reload.organization_requests.pending.count
    request = MembershipRequest.new(user:, organization:)
    request.save

    assert_equal 1, user.reload.organization_requests.pending.count

    assert_difference 'AccessRequest::UserRequestForOrganization.count', -1 do
      delete user_membership_request_path(user.reload.organization_requests.pending.first)
      assert_response :redirect
      assert_equal I18n.t('users.membership_requests.destroy.success'), flash[:notice]
    end
  end
end
