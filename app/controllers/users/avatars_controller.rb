# frozen_string_literal: true

class Users::AvatarsController < ApplicationController
  def destroy
    current_user.avatar.purge
    redirect_to edit_user_path
  end
end
