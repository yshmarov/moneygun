class CreateConnectedAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :connected_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
