class AddUnconfirmedEmailToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :unconfirmed_email, :string
  end
end
