class Users::ConnectedAccountsController < ApplicationController
  before_action :set_connected_account, only: [ :destroy ]

  def index
    @connected_accounts = current_user.connected_accounts
  end

  def destroy
    @connected_account.destroy
    redirect_to user_connected_accounts_path, notice: "Account disconnected successfully."
  end

  private

  def set_connected_account
    @connected_account = current_user.connected_accounts.find(params[:id])
  end
end
