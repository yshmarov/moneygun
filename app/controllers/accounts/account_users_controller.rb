class Accounts::AccountUsersController < Accounts::BaseController
  def index
    @account_users = @account.account_users
  end

  def new
  end

  def create
    email = params[:email]
    return redirect_to account_account_users_path(@account), alert: 'No email provided' if email.blank?

    user = User.find_by(email:) || User.invite!({ email: }, current_user)
    return redirect_to account_account_users_path(@account), alert: 'Email invalid' unless user.valid?

    user.account_users.find_or_create_by(account: @account, role: AccountUser.roles[:member])
    redirect_to account_account_users_path(@account), notice: "#{email} invited!"
  end
end
