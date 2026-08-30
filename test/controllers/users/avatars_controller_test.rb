# frozen_string_literal: true

require "test_helper"

class Users::AvatarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.avatar.attach(io: file_fixture("avo-logo.png").open, filename: "avatar.png", content_type: "image/png")
  end

  test "destroy purges the avatar" do
    sign_in @user

    delete user_avatar_url

    assert_redirected_to edit_user_path
    assert_not @user.reload.avatar.attached?
  end

  test "destroy requires authentication" do
    delete user_avatar_url

    assert_redirected_to new_session_url
    assert_predicate @user.reload.avatar, :attached?
  end
end
