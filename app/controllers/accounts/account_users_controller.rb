class Accounts::AccountUsersController < Accounts::BaseController
  before_action :set_account_user, only: [ :edit, :update, :destroy ]

  def index
    @account_users = @account.account_users.includes(:user)
  end

  def new
    authorize @account.account_users.new
    @form = AccountUserInvitation.new(account: @account, role: AccountUser.roles[:member])
  end

  def create
    authorize @account.account_users.new
    @form = AccountUserInvitation.new(email: params.dig(:account_user_invitation, :email), role: params.dig(:account_user_invitation, :role), account: @account, inviter: current_user)

    if @form.save
      redirect_to account_account_users_path(@account), notice: "#{@form.email} invited!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account_user.update(account_user_params)
      redirect_to account_account_users_path(@account), notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @account_user.try_destroy
      if @account_user.user == current_user
        redirect_to accounts_path, notice: "You have left that account"
      else
        redirect_to account_account_users_path(@account), notice: "User removed from account"
      end
    else
      redirect_to account_account_users_path(@account), alert: "Failed to remove user from account"
    end
  end

  private

  def set_account_user
    @account_user = @account.account_users.find(params[:id])
    authorize @account_user
  end

  def account_user_params
    params.require(:account_user).permit(:role)
  end
end
