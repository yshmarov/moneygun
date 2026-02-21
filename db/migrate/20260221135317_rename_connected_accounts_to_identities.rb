# frozen_string_literal: true

class RenameConnectedAccountsToIdentities < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      rename_table :connected_accounts, :identities

      # Replace polymorphic owner with direct user_id
      # Drop both indexes on [owner_type, owner_id] by name (use execute for reliability after rename)
      execute "DROP INDEX IF EXISTS index_connected_accounts_on_owner"
      execute "DROP INDEX IF EXISTS index_connected_accounts_on_owner_type_and_owner_id"
      remove_column :identities, :owner_type, :string
      rename_column :identities, :owner_id, :user_id
      add_index :identities, :user_id

      # Add token refresh tracking
      add_column :identities, :refresh_token_invalidated_at, :datetime
      add_index :identities, :refresh_token_invalidated_at
    end
  end
end
