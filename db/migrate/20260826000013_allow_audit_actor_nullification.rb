# frozen_string_literal: true

class AllowAuditActorNullification < ActiveRecord::Migration[8.1]
  def up
    drop_trigger :audit_logs_block_truncate, on: :audit_logs
    drop_trigger :audit_logs_block_update, on: :audit_logs
    drop_function :audit_logs_append_only

    create_function :audit_logs_block_update
    create_function :audit_logs_block_truncate
    create_trigger :audit_logs_append_only_update, on: :audit_logs
    create_trigger :audit_logs_append_only_truncate, on: :audit_logs
  end

  def down
    drop_trigger :audit_logs_append_only_truncate, on: :audit_logs
    drop_trigger :audit_logs_append_only_update, on: :audit_logs
    drop_function :audit_logs_block_truncate
    drop_function :audit_logs_block_update

    create_function :audit_logs_append_only
    create_trigger :audit_logs_block_update, on: :audit_logs
    create_trigger :audit_logs_block_truncate, on: :audit_logs
  end
end
