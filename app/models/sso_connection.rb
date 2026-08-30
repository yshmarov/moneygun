# frozen_string_literal: true

class SsoConnection < ApplicationRecord
  NAME_IDENTIFIER_FORMAT = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  belongs_to :organization
  has_many :saml_auth_requests, dependent: :delete_all
  has_many :sso_domains, dependent: :destroy

  validates :organization_id, uniqueness: true
  validates :enabled, :enforced, :jit_provisioning, inclusion: { in: [true, false] }
  validates :default_membership_role, inclusion: { in: Membership.roles.keys }
  validates :idp_entity_id, :idp_sso_url, :idp_cert, presence: true, if: :enabled?
  validate :idp_cert_must_parse, if: -> { idp_cert.present? }
  validate :idp_sso_url_must_be_a_web_url, if: -> { idp_sso_url.present? }
  validate :enabled_connection_needs_a_verified_domain, if: :enabled?

  scope :enabled, -> { where(enabled: true) }
  scope :for_domain, ->(domain) { joins(:sso_domains).merge(SsoDomain.verified.where(domain: domain)) }

  def self.domain_for(email)
    email.to_s.split("@").last&.strip&.downcase.presence
  end

  def self.discoverable_for_email(email)
    domain = domain_for(email)
    enabled.for_domain(domain).first if domain
  end

  def self.enforced_for_email(email)
    domain = domain_for(email)
    enabled.where(enforced: true).for_domain(domain).first if domain
  end

  def configured?
    idp_entity_id.present? && idp_sso_url.present? && idp_certs.any?
  end

  def idp_certs
    idp_cert.to_s.scan(/-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m).presence || Array(idp_cert.presence)
  end

  def idp_cert_expires_at
    parsed_idp_certs.filter_map(&:not_after).max
  end

  def idp_cert_expired? = idp_cert_expires_at&.past? || false

  def asserts_email?(email)
    domain = self.class.domain_for(email)
    domain.present? && sso_domains.verified.exists?(domain: domain)
  end

  def sign_in_membership(asserted_email, name: nil)
    email = asserted_email.to_s.strip.downcase
    return unless asserts_email?(email)

    user = User.find_by(email: email)
    return if user && !user.can_authenticate?

    membership = user && organization.memberships.find_by(user: user)
    return membership if membership&.active?
    return unless jit_provisioning?

    if membership
      reactivate(membership)
    elsif user.nil?
      provision(email, name)
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def saml_options(base_url:)
    {
      idp_entity_id: idp_entity_id,
      idp_sso_service_url: idp_sso_url,
      idp_cert_multi: { signing: idp_certs, encryption: [] },
      sp_entity_id: "#{base_url}/auth/saml/metadata",
      assertion_consumer_service_url: "#{base_url}/auth/saml/callback",
      name_identifier_format: NAME_IDENTIFIER_FORMAT,
      allowed_clock_drift: 30.seconds,
      security: {
        want_assertions_signed: true,
        strict_audience_validation: true,
        digest_method: XMLSecurity::Document::SHA256,
        signature_method: XMLSecurity::Document::RSA_SHA256
      }
    }
  end

  private

  def enabled_connection_needs_a_verified_domain
    errors.add(:base, :no_verified_domain) unless sso_domains.any?(&:verified?)
  end

  def idp_sso_url_must_be_a_web_url
    url = URI.parse(idp_sso_url)
    schemes = Rails.env.local? ? [URI::HTTP, URI::HTTPS] : [URI::HTTPS]
    return if schemes.any? { |scheme| url.instance_of?(scheme) } && url.host.present? && !idp_sso_url.match?(/[;\s]/)

    errors.add(:idp_sso_url, :invalid)
  rescue URI::InvalidURIError
    errors.add(:idp_sso_url, :invalid)
  end

  def idp_cert_must_parse
    errors.add(:idp_cert, :not_a_certificate) if parsed_idp_certs.size != idp_certs.size
  end

  def parsed_idp_certs
    idp_certs.filter_map do |pem|
      OpenSSL::X509::Certificate.new(OneLogin::RubySaml::Utils.format_cert(pem))
    rescue OpenSSL::X509::CertificateError
      nil
    end
  end

  def reactivate(membership)
    membership.update!(deactivated_at: nil, provisioned_via: "sso")
    membership
  end

  def provision(email, name)
    transaction do
      user = User.create!(email: email, name: name.presence || email)
      organization.memberships.create!(user: user, role: default_membership_role, provisioned_via: "sso")
    end
  end
end
