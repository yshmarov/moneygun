# frozen_string_literal: true

class SsoDomain < ApplicationRecord
  TXT_PREFIX = "moneygun-verification"

  belongs_to :sso_connection
  has_secure_token :verification_token

  normalizes :domain, with: ->(value) { value.to_s.strip.downcase.delete_prefix("@").presence }

  validates :domain, presence: true, uniqueness: { scope: :sso_connection_id },
                     format: { with: /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+\z/ }
  validate :verified_domain_is_not_claimed_elsewhere, if: :verified?

  scope :verified, -> { where.not(verified_at: nil) }
  scope :pending, -> { where(verified_at: nil) }
  scope :ordered, -> { order(:domain) }

  def verified? = verified_at.present?
  def txt_record = "#{TXT_PREFIX}=#{verification_token}"

  def verify!
    return true if verified?
    return false unless published_in_dns?

    update(verified_at: Time.current)
  end

  private

  def published_in_dns?
    Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::TXT).flat_map(&:strings).include?(txt_record)
    end
  rescue Resolv::ResolvError, Resolv::ResolvTimeout, IOError, SocketError
    false
  end

  def verified_domain_is_not_claimed_elsewhere
    errors.add(:domain, :taken) if self.class.verified.where(domain: domain).where.not(id: id).exists?
  end
end
