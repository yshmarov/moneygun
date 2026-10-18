# frozen_string_literal: true

class RemoveSolidCableChannelIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :solid_cable_messages, :channel, algorithm: :concurrently, if_exists: true
  end
end
