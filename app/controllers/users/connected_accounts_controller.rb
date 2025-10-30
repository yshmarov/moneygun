# frozen_string_literal: true

class Users::ConnectedAccountsController < ApplicationController
  before_action :set_connected_account, only: %i[destroy]

  def index
    @connected_accounts = current_user.connected_accounts
  end

  def destroy
    @connected_account.destroy
    redirect_to user_connected_accounts_path, notice: I18n.t("users.connected_accounts.destroy.success")
  end

  private

  def set_connected_account
    @connected_account = current_user.connected_accounts.find(params[:id])
  end
end
