class MakeConnectedAccountsPolymorphic < ActiveRecord::Migration[8.0]
  def change
    # Remove the foreign key constraint first
    remove_foreign_key :connected_accounts, :users

    # Remove the user_id column and its index
    remove_index :connected_accounts, :user_id
    remove_column :connected_accounts, :user_id

    # Add polymorphic columns
    add_reference :connected_accounts, :owner, polymorphic: true, null: false, index: true

    # Add index for polymorphic relationship
    add_index :connected_accounts, %i[owner_type owner_id]
  end
end
