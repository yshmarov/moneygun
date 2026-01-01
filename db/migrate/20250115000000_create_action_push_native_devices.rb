# frozen_string_literal: true

class CreateActionPushNativeDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :action_push_native_devices do |t|
      t.string :name
      t.string :platform, null: false
      t.string :token, null: false
      t.belongs_to :owner, polymorphic: true

      t.timestamps
    end
  end
end

