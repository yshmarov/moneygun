# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  def show; end

  private

  def set_user
    @user = current_user
  end
end
