# frozen_string_literal: true

class DropUnusedTables < ActiveRecord::Migration[8.1]
  def change
    # Remove foreign keys first (order matters due to dependencies)
    remove_foreign_key :tool_calls, :messages
    remove_foreign_key :messages, :tool_calls
    remove_foreign_key :messages, :models
    remove_foreign_key :messages, :chats
    remove_foreign_key :chats, :models

    # Drop tables in order (dependent tables first)
    drop_table :tool_calls do |t|
      t.string :tool_call_id, null: false
      t.string :name, null: false
      t.jsonb :arguments, default: {}
      t.bigint :message_id, null: false
      t.timestamps

      t.index :message_id
      t.index :name
      t.index :tool_call_id, unique: true
    end

    drop_table :messages do |t|
      t.bigint :chat_id, null: false
      t.string :role, null: false
      t.text :content
      t.json :content_raw
      t.bigint :model_id
      t.integer :input_tokens
      t.integer :output_tokens
      t.integer :cached_tokens
      t.integer :cache_creation_tokens
      t.bigint :tool_call_id
      t.timestamps

      t.index :chat_id
      t.index :model_id
      t.index :role
      t.index :tool_call_id
    end

    drop_table :chats do |t|
      t.bigint :model_id
      t.timestamps

      t.index :model_id
    end

    drop_table :models do |t|
      t.string :model_id, null: false
      t.string :name, null: false
      t.string :provider, null: false
      t.integer :context_window
      t.integer :max_output_tokens
      t.string :family
      t.date :knowledge_cutoff
      t.datetime :model_created_at
      t.jsonb :pricing, default: {}
      t.jsonb :metadata, default: {}
      t.jsonb :modalities, default: {}
      t.jsonb :capabilities, default: []
      t.timestamps

      t.index [:provider, :model_id], unique: true
      t.index :provider
      t.index :family
      t.index :modalities, using: :gin
      t.index :capabilities, using: :gin
    end

    drop_table :action_push_native_devices do |t|
      t.string :token, null: false
      t.string :platform, null: false
      t.string :name
      t.string :owner_type
      t.bigint :owner_id
      t.timestamps

      t.index [:owner_type, :owner_id], name: "index_action_push_native_devices_on_owner"
    end

    # Remove duplicate index on connected_accounts
    remove_index :connected_accounts, name: "index_connected_accounts_on_owner_type_and_owner_id"
  end
end
