class AddAutoRefillToWallets < ActiveRecord::Migration[8.0]
  def change
    add_column :usage_credits_wallets, :auto_refill_enabled, :boolean, default: false, null: false
    add_column :usage_credits_wallets, :auto_refill_credit_pack, :string
  end
end
