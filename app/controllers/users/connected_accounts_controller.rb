class Users::ConnectedAccountsController < ApplicationController
  def index
    @connected_accounts = current_user.connected_accounts
  end
end
