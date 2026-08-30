# frozen_string_literal: true

class AddPasswordlessAuthentication < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.datetime :last_seen_at
      t.timestamps
    end

    create_table :magic_links do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code, null: false
      t.string :purpose, null: false, default: "sign_in"
      t.datetime :expires_at, null: false
      t.string :new_email
      t.timestamps
    end

    add_index :magic_links, :code, unique: true
    add_index :magic_links, :expires_at

    add_column :users, :email_verified_at, :datetime
    add_column :users, :otp_secret, :text
    add_column :users, :otp_backup_codes, :text
    add_column :users, :otp_enabled_at, :datetime
  end
end
