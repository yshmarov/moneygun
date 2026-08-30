# frozen_string_literal: true

class ValidateProjectMembershipForeignKey < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :projects, :memberships, validate: false
  end
end
