# frozen_string_literal: true

class MagicLink < ApplicationRecord
  CODE_LENGTH = 6
  EXPIRATION_TIME = 15.minutes

  belongs_to :user

  enum :purpose, %w[sign_in sign_up email_change sudo].index_by(&:itself), prefix: :for, default: :sign_in

  SIGN_IN_PURPOSES = %w[sign_in sign_up].freeze

  scope :active, -> { where(expires_at: Time.current...) }
  scope :stale, -> { where(expires_at: ..Time.current) }
  scope :for_email, ->(email) { joins(:user).where(users: { email: email }) }

  before_validation :generate_code, on: :create
  before_validation :set_expiration, on: :create

  validates :code, uniqueness: true, presence: true
  validates :expires_at, presence: true
  validates :new_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :for_email_change?

  class << self
    def consume(code, purpose: nil, new_email: nil)
      scope = active
      scope = scope.where(purpose: Array(purpose)) if purpose
      scope = scope.where(new_email: new_email) if new_email.present?

      transaction do
        magic_link = scope.lock.find_by(code: Code.sanitize(code))
        next unless magic_link

        magic_link.destroy!
        magic_link
      end
    end

    def cleanup
      stale.delete_all
    end

    def purposes_sharing_slot_with(purpose)
      purpose = purpose.presence&.to_s || "sign_in"

      purpose.in?(SIGN_IN_PURPOSES) ? SIGN_IN_PURPOSES : [purpose]
    end
  end

  private

  def generate_code
    self.code ||= loop do
      candidate = Code.generate(CODE_LENGTH)
      break candidate unless self.class.exists?(code: candidate)
    end
  end

  def set_expiration
    self.expires_at ||= EXPIRATION_TIME.from_now
  end
end
