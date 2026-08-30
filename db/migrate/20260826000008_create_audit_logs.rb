# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def up
    create_table :audit_logs do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.string :mini_app, null: false, default: "organization"
      t.string :action, null: false
      t.string :actor_kind, null: false
      t.references :actor, polymorphic: true, null: true
      t.references :subject, polymorphic: true, null: true, index: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps

      t.index %i[organization_id created_at]
      t.index %i[subject_type subject_id]
      t.index :mini_app
    end

    create_function :audit_logs_append_only
    create_trigger :audit_logs_block_update, on: :audit_logs
    create_trigger :audit_logs_block_truncate, on: :audit_logs
  end

  def down
    drop_trigger :audit_logs_block_truncate, on: :audit_logs
    drop_trigger :audit_logs_block_update, on: :audit_logs
    drop_function :audit_logs_append_only
    drop_table :audit_logs
  end
end
