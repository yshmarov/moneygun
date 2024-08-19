class Accounts::BaseController < ApplicationController
  # the order of the before_actions is important
  before_action :set_account
  before_action :authorize_account_user!
  before_action :set_current_account_user

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  end

  def authorize_account_user!
    redirect_to root_path, alert: "You are not authorized to perform this action." unless @account.users.include?(current_user)
  end

  def set_current_account_user
    @current_account_user ||= current_user.account_users.find_by(account: @account)
  end

  def authorize_account_admin!
    redirect_to account_path(@account), alert: "You are not authorized to perform this action." unless @current_account_user.admin?
  end
end
