class AddUniqueIndexToConnectedAccountsUidAndProvider < ActiveRecord::Migration[8.0]
  def change
    add_index :connected_accounts, [:uid, :provider], unique: true
  end
end
