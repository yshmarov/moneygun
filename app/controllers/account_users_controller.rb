class AccountUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_account

  def index
    @account_users = @current_account.account_users
  end

  private

  def set_current_account
    @current_account = current_user.accounts.find(params[:account_id])
  end
end
