# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action -> { require_sudo(:delete_account) }, only: :destroy

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to user_path }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(user_path) }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    reasons = @user.undeletable_reasons
    if reasons.any?
      redirect_to user_path, alert: helpers.blocking_reasons_sentence(reasons, scope: "users.security.delete_account_disabled")
      return
    end

    terminate_session
    @user.erase!
    redirect_to new_session_path
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.expect(user: %i[name avatar marketing_consent])
  end
end
