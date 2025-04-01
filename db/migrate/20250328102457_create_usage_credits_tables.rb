# frozen_string_literal: true

class CreateUsageCreditsTables < ActiveRecord::Migration[8.0]
  def change
    primary_key_type, foreign_key_type = primary_and_foreign_key_types

    create_table :usage_credits_wallets, id: primary_key_type do |t|
      t.references :owner, polymorphic: true, null: false, type: foreign_key_type
      t.integer :balance, null: false, default: 0
      t.send(json_column_type, :metadata, null: false, default: {})

      t.timestamps
    end

    create_table :usage_credits_transactions, id: primary_key_type do |t|
      t.references :wallet, null: false, type: foreign_key_type
      t.integer :amount, null: false
      t.string :category, null: false
      t.datetime :expires_at
      t.references :fulfillment, type: foreign_key_type
      t.send(json_column_type, :metadata, null: false, default: {})

      t.timestamps
    end

    create_table :usage_credits_fulfillments, id: primary_key_type do |t|
      t.references :wallet, null: false, type: foreign_key_type
      t.references :source, polymorphic: true, type: foreign_key_type
      t.integer :credits_last_fulfillment, null: false    # Credits given in last fulfillment
      t.string :fulfillment_type, null: false             # What kind of fulfillment is this? (credit_pack / subscription)
      t.datetime :last_fulfilled_at                       # When last fulfilled
      t.datetime :next_fulfillment_at                     # When to fulfill next (nil if stopped/completed)
      t.string :fulfillment_period                        # "2.months", "15.days", etc. (nil for one-time)
      t.datetime :stops_at                                # When to stop performing fulfillments
      t.send(json_column_type, :metadata, null: false, default: {})

      t.timestamps
    end

    # Allocations are the basis for the bucket-based, FIFO with expiration inventory-like system
    create_table :usage_credits_allocations, id: primary_key_type do |t|
      # The "spend" transaction (negative) that is *using* credits
      t.references :transaction, null: false, type: foreign_key_type,
                                 foreign_key: { to_table: :usage_credits_transactions },
                                 index: { name: "index_allocations_on_transaction_id" }

      # The "source" transaction (positive) from which the credits are drawn
      t.references :source_transaction, null: false, type: foreign_key_type,
                                        foreign_key: { to_table: :usage_credits_transactions },
                                        index: { name: "index_allocations_on_source_transaction_id" }

      # How many credits were allocated from that particular source
      t.integer :amount, null: false

      t.timestamps
    end

    # Add indexes
    add_index :usage_credits_transactions, :category
    add_index :usage_credits_transactions, :expires_at

    # Composite index on (expires_at, id) for efficient ordering when calculating balances
    add_index :usage_credits_transactions, [ :expires_at, :id ], name: 'index_transactions_on_expires_at_and_id'

    # Index on wallet_id and amount to speed up queries filtering by wallet and positive amounts
    add_index :usage_credits_transactions, [ :wallet_id, :amount ], name: 'index_transactions_on_wallet_id_and_amount'

    add_index :usage_credits_allocations, [ :transaction_id, :source_transaction_id ], name: "index_allocations_on_tx_and_source_tx"

    add_index :usage_credits_fulfillments, :next_fulfillment_at
    add_index :usage_credits_fulfillments, :fulfillment_type
  end

  private

  def primary_and_foreign_key_types
    config = Rails.configuration.generators
    setting = config.options[config.orm][:primary_key_type]
    primary_key_type = setting || :primary_key
    foreign_key_type = setting || :bigint
    [ primary_key_type, foreign_key_type ]
  end

  def json_column_type
    return :jsonb if connection.adapter_name.downcase.include?('postgresql')
    :json
  end
end
