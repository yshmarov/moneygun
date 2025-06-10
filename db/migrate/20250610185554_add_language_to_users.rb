class AddLanguageToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :locale, :string
  end
end
