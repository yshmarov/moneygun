# frozen_string_literal: true

class ScimConnection < ApplicationRecord
  TOKEN_PREFIX = "scim_"

  belongs_to :organization
  attr_reader :token

  before_validation :ensure_token, on: :create

  validates :token_digest, presence: true, uniqueness: true
  validates :organization_id, uniqueness: true
  validates :default_membership_role, inclusion: { in: Membership.roles.keys }

  def self.authenticate(token)
    find_by(token_digest: digest(token)) if token.present?
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  def regenerate_token!
    self.token_digest = self.class.digest(generate_token)
    save!
    token
  end

  private

  def ensure_token
    self.token_digest ||= self.class.digest(generate_token)
  end

  def generate_token
    @token = TOKEN_PREFIX + SecureRandom.urlsafe_base64(32)
    self.token_last_four = @token.last(4)
    @token
  end
end
