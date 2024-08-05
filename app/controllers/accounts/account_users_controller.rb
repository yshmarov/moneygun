class Accounts::AccountUsersController < Accounts::BaseController
  before_action :set_account_user, only: [ :destroy ]
  before_action :authorize_account_admin!, only: [ :new, :create, :destroy ]

  def index
    @account_users = @account.account_users
  end

  def new
  end

  def create
    email = params[:email]
    return redirect_to account_account_users_path(@account), alert: "No email provided" if email.blank?

    user = User.find_by(email:) || User.invite!({ email: }, current_user)
    return redirect_to account_account_users_path(@account), alert: "Email invalid" unless user.valid?

    user.account_users.find_or_create_by(account: @account, role: AccountUser.roles[:member])
    redirect_to account_account_users_path(@account), notice: "#{email} invited!"
  end

  def destroy
    if @account_user.try_destroy
      redirect_to account_account_users_path(@account), notice: "User removed from account"
    else
      redirect_to account_account_users_path(@account), alert: "Failed to remove user from account"
    end
  end

  private

  def set_account_user
    @account_user = @account.account_users.find(params[:id])
  end
end
