class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.timestamps
    end
  end
end
