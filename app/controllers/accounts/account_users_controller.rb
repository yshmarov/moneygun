class Accounts::AccountUsersController < Accounts::BaseController
  before_action :set_account_user, only: [ :edit, :update, :destroy ]
  before_action :authorize_account_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @account_users = @account.account_users
  end

  def new
  end

  def create
    email = params[:email]
    return redirect_to new_account_account_user_path(@account), alert: "No email provided" if email.blank?

    user = User.find_by(email:) || User.invite!({ email: }, current_user)
    return redirect_to new_account_account_user_path(@account), alert: "Email invalid" unless user.valid?

    account_user = user.account_users.find_by(account: @account)
    if account_user.present?
      redirect_to account_account_users_path(@account), alert: "#{email} is already a member of this account."
    else
      user.account_users.create(account: @account, role: AccountUser.roles[:member])
      redirect_to account_account_users_path(@account), notice: "#{email} invited!"
    end
  end

  def edit
    redirect_to account_account_users_path(@account), alert: "Can not edit yourself" if @account_user.user == current_user
  end

  def update
    return redirect_to account_account_users_path(@account), alert: "Can not edit yourself" if @account_user.user == current_user

    if @account_user.update(account_user_params)
      redirect_to account_account_users_path(@account), notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
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

  def account_user_params
    params.require(:account_user).permit(:role)
  end
end
