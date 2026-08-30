# frozen_string_literal: true

module User::Authentication
  extend ActiveSupport::Concern

  BLOCKED_EMAIL_TLDS = %w[.ru .su].freeze

  included do
    has_many :sessions, dependent: :delete_all
    has_many :magic_links, dependent: :delete_all
    validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :email, nondisposable: true
    validate :reject_blocked_email_tlds

    normalizes :email, with: ->(value) { value.strip.downcase.presence }
  end

  def send_magic_link(**attributes)
    attributes[:purpose] = attributes.delete(:for) if attributes.key?(:for)

    magic_link = with_lock do
      magic_links.where(purpose: MagicLink.purposes_sharing_slot_with(attributes[:purpose])).delete_all
      magic_links.create!(attributes)
    end

    deliver_magic_link(magic_link)
    magic_link
  end

  def can_authenticate?
    !banned? && !redacted?
  end

  def can_authenticate_with_magic_link?
    can_authenticate? && SsoConnection.enforced_for_email(email).nil?
  end

  def email_verified?
    email_verified_at.present?
  end

  def verify_email!
    with_lock { update!(email_verified_at: Time.current) unless email_verified? }
  end

  private

  def deliver_magic_link(magic_link)
    case magic_link.purpose
    when "email_change" then MagicLinkMailer.email_change_verification(magic_link).deliver_later
    when "sudo" then MagicLinkMailer.sudo_code(magic_link).deliver_later
    else MagicLinkMailer.sign_in_instructions(magic_link).deliver_later
    end
  end

  def reject_blocked_email_tlds
    return if email.blank?

    domain = email.split("@", 2).last
    return if domain.blank?

    errors.add(:email, :blocked_email) if BLOCKED_EMAIL_TLDS.any? { |tld| domain.downcase.end_with?(tld) }
  end
end
