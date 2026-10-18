# frozen_string_literal: true

class AddTokenToSessions < ActiveRecord::Migration[8.1]
  def up
    add_column :sessions, :token, :string
    safety_assured do
      execute "DELETE FROM sessions"
      change_column_null :sessions, :token, false
      add_index :sessions, :token, unique: true
    end
  end

  def down
    remove_column :sessions, :token
  end
end
