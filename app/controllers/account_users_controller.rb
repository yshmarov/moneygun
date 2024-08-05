class AccountUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_account

  def index
    @account_users = @current_account.account_users
  end

  def new
  end

  def create
    email = params[:email]
    return redirect_to account_account_users_path(@current_account), alert: 'No email provided' if email.blank?

    user = User.find_by(email:) || User.invite!({ email: }, current_user)
    return redirect_to account_account_users_path(@current_account), alert: 'Email invalid' unless user.valid?

    user.account_users.find_or_create_by(account: @current_account, role: AccountUser.roles[:member])
    redirect_to account_account_users_path(@current_account), notice: "#{email} invited!"
  end

  private

  def set_current_account
    @current_account = current_user.accounts.find(params[:account_id])
  end
end
