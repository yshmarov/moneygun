# frozen_string_literal: true

class AddIndexToMembershipsRole < ActiveRecord::Migration[8.0]
  def change
    add_index :memberships, :role
  end
end

