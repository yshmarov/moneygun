# frozen_string_literal: true

class AddMembershipToProjects < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :projects, :membership, null: true, index: { algorithm: :concurrently }
  end
end
