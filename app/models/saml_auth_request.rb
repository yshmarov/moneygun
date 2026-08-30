# frozen_string_literal: true

class SamlAuthRequest < ApplicationRecord
  TTL = SamlFlowCookie::TTL

  belongs_to :sso_connection
  validates :request_id, :expires_at, presence: true

  scope :pending, -> { where(expires_at: Time.current..) }
  scope :stale, -> { where(expires_at: ..Time.current) }

  def self.start(request_id, sso_connection_id:)
    where(sso_connection_id: sso_connection_id).stale.delete_all
    create!(request_id: request_id, sso_connection_id: sso_connection_id, expires_at: TTL.from_now)
  end

  def self.consume(request_id, sso_connection_id:)
    return false if request_id.blank? || sso_connection_id.blank?

    pending.where(request_id: request_id, sso_connection_id: sso_connection_id).delete_all == 1
  end

  def self.cleanup = stale.delete_all
end
