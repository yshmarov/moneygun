# frozen_string_literal: true

class ConfirmProjectMembershipForeignKey < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    validate_foreign_key :projects, :memberships
  end
end
