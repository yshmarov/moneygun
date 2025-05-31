class AddPayloadToConnectedAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :connected_accounts, :payload, :jsonb
  end
end
