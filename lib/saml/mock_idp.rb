# frozen_string_literal: true

# A SAML 2.0 identity provider that exists to be signed into.
#
# It mints genuinely signed assertions from a throwaway keypair, so tests and
# manual QA drive ruby-saml's real validation — signature, digest, audience,
# conditions, InResponseTo, destination — instead of stubbing the protocol out
# with OmniAuth's test mode. Every keyword that shapes the response doubles as a
# tamper knob, which is how the negative cases get their malformed input.
#
# Development and test only: nothing in production has any business minting an
# assertion, so the constructor refuses to run there.
module Saml
  class MockIdp
    class ProductionUseError < StandardError
    end

    NAMEID_FORMAT = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    BEARER = "urn:oasis:names:tc:SAML:2.0:cm:bearer"
    SUCCESS = "urn:oasis:names:tc:SAML:2.0:status:Success"
    AUTHN_CONTEXT = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    PROTOCOL_NS = "urn:oasis:names:tc:SAML:2.0:protocol"
    ASSERTION_NS = "urn:oasis:names:tc:SAML:2.0:assertion"
    METADATA_NS = "urn:oasis:names:tc:SAML:2.0:metadata"
    REDIRECT_BINDING = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"

    attr_reader :entity_id, :sso_url, :certificate

    def initialize(entity_id:, sso_url:, keypair: self.class.keypair)
      raise ProductionUseError, "Saml::MockIdp is a development and test tool" unless Rails.env.local?

      @entity_id = entity_id
      @sso_url = sso_url
      @private_key, @certificate = keypair
    end

    def certificate_pem = certificate.to_pem

    # What a real IdP publishes about itself. The settings form takes the entity
    # id, sign-on URL, and certificate as separate fields, so this is here to be
    # read rather than imported.
    def metadata
      XMLSecurity::Document.new.tap do |document|
        descriptor = document.add_element("md:EntityDescriptor",
                                          "xmlns:md" => METADATA_NS, "entityID" => entity_id)
        idp = descriptor.add_element("md:IDPSSODescriptor",
                                     "protocolSupportEnumeration" => PROTOCOL_NS)
        key_descriptor = idp.add_element("md:KeyDescriptor", "use" => "signing")
        key_info = key_descriptor.add_element("ds:KeyInfo", "xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#")
        x509 = key_info.add_element("ds:X509Data")
        x509.add_element("ds:X509Certificate").text = der_base64
        idp.add_element("md:NameIDFormat").text = NAMEID_FORMAT
        idp.add_element("md:SingleSignOnService", "Binding" => REDIRECT_BINDING, "Location" => sso_url)
      end
    end

    # A base64 SAMLResponse, ready to POST to the service provider's ACS.
    #
    # The defaults produce the assertion a well-behaved IdP would send. Overrides
    # exist so a test can send a badly-behaved one.
    def sign_in(email:, acs_url:, sp_entity_id:, in_response_to:,
                name: nil, audience: sp_entity_id, destination: acs_url,
                recipient: acs_url, issuer: entity_id, assertion_issuer: entity_id,
                nameid_format: NAMEID_FORMAT, status: SUCCESS,
                subject_in_response_to: in_response_to,
                not_before: 5.minutes.ago, not_on_or_after: 5.minutes.from_now,
                sign_assertion: true, sign_response: false, signing_keypair: nil)
      assertion = build_assertion(
        email:, name:, audience:, recipient:, issuer: assertion_issuer, nameid_format:,
        in_response_to: subject_in_response_to, not_before:, not_on_or_after:
      )
      response = build_response(assertion:, issuer:, destination:, in_response_to:, status:)

      # Assertion first: the response's own digest has to cover the signature
      # already sitting inside it.
      sign_in_place(response, assertion.attributes["ID"], signing_keypair) if sign_assertion
      sign_in_place(response, response.root.attributes["ID"], signing_keypair) if sign_response

      Base64.strict_encode64(response.to_s)
    end

    # The AuthnRequest a service provider sent us, as far as a mock IdP cares:
    # which request the response must answer and where to send it.
    def self.parse_authn_request(encoded)
      xml = OneLogin::RubySaml::SamlMessage.new.send(:decode_raw_saml, encoded, OneLogin::RubySaml::Settings.new)
      document = REXML::Document.new(xml)
      root = document.root
      return {} unless root

      {
        id: root.attributes["ID"],
        acs_url: root.attributes["AssertionConsumerServiceURL"],
        issuer: REXML::XPath.first(root, "//saml:Issuer", "saml" => ASSERTION_NS)&.text
      }
    rescue StandardError
      {}
    end

    # One keypair per process. Development persists it under tmp/ so a connection
    # configured against the mock IdP survives a server restart.
    def self.keypair
      @keypair ||= Rails.env.development? ? persisted_keypair : generate_keypair
    end

    def self.generate_keypair
      key = OpenSSL::PKey::RSA.new(2048)
      certificate = OpenSSL::X509::Certificate.new
      certificate.version = 2
      certificate.serial = 1
      certificate.subject = certificate.issuer = OpenSSL::X509::Name.new([["CN", "Mock SAML IdP"]])
      certificate.public_key = key.public_key
      certificate.not_before = 1.hour.ago.to_time
      certificate.not_after = 10.years.from_now.to_time
      certificate.sign(key, OpenSSL::Digest.new("SHA256"))
      [key, certificate]
    end

    def self.persisted_keypair
      path = Rails.root.join("tmp/mock_saml_idp.pem")
      if path.exist?
        pem = path.read
        [OpenSSL::PKey::RSA.new(pem), OpenSSL::X509::Certificate.new(pem)]
      else
        generate_keypair.tap { |key, certificate| path.write(key.to_pem + certificate.to_pem) }
      end
    end

    private

    def build_assertion(email:, name:, audience:, recipient:, issuer:, nameid_format:,
                        in_response_to:, not_before:, not_on_or_after:)
      # Element order is fixed by the SAML schema, which ruby-saml validates the
      # response against: Issuer, Signature, Subject, Conditions, statements.
      REXML::Element.new("saml:Assertion").tap do |assertion|
        assertion.add_attributes("xmlns:saml" => ASSERTION_NS,
                                 "ID" => identifier,
                                 "Version" => "2.0",
                                 "IssueInstant" => timestamp(Time.current))
        assertion.add_element("saml:Issuer").text = issuer

        subject = assertion.add_element("saml:Subject")
        subject.add_element("saml:NameID", "Format" => nameid_format).text = email
        confirmation = subject.add_element("saml:SubjectConfirmation", "Method" => BEARER)
        confirmation.add_element("saml:SubjectConfirmationData",
                                 "NotOnOrAfter" => timestamp(not_on_or_after),
                                 "Recipient" => recipient,
                                 "InResponseTo" => in_response_to)

        conditions = assertion.add_element("saml:Conditions",
                                           "NotBefore" => timestamp(not_before),
                                           "NotOnOrAfter" => timestamp(not_on_or_after))
        conditions.add_element("saml:AudienceRestriction")
                  .add_element("saml:Audience").text = audience

        statement = assertion.add_element("saml:AuthnStatement",
                                          "AuthnInstant" => timestamp(Time.current),
                                          "SessionIndex" => identifier)
        statement.add_element("saml:AuthnContext")
                 .add_element("saml:AuthnContextClassRef").text = AUTHN_CONTEXT

        attributes = assertion.add_element("saml:AttributeStatement")
        add_attribute(attributes, "email", email)
        add_attribute(attributes, "name", name) if name.present?
      end
    end

    def build_response(assertion:, issuer:, destination:, in_response_to:, status:)
      XMLSecurity::Document.new.tap do |document|
        response = document.add_element("samlp:Response",
                                        "xmlns:samlp" => PROTOCOL_NS,
                                        "xmlns:saml" => ASSERTION_NS,
                                        "ID" => identifier,
                                        "Version" => "2.0",
                                        "IssueInstant" => timestamp(Time.current),
                                        "Destination" => destination,
                                        "InResponseTo" => in_response_to)
        response.add_element("saml:Issuer").text = issuer
        response.add_element("samlp:Status")
                .add_element("samlp:StatusCode", "Value" => status)
        response.add_element(assertion)
      end
    end

    def add_attribute(statement, name, value)
      attribute = statement.add_element("saml:Attribute",
                                        "Name" => name,
                                        "NameFormat" => "urn:oasis:names:tc:SAML:2.0:attrname-format:basic")
      attribute.add_element("saml:AttributeValue").text = value
    end

    # Signs one element of the finished response, in place, the way a real IdP
    # does. Signing the assertion as a standalone document instead would produce
    # a signature that stops verifying the moment it is embedded: exclusive
    # canonicalization treats the PrefixList as inclusive, so the assertion's
    # canonical form picks up the samlp declaration from the response root.
    def sign_in_place(document, element_id, keypair)
      key, certificate = keypair || [@private_key, @certificate]

      element = REXML::XPath.first(document, "//*[@ID=$id]", nil, { "id" => element_id })
      digest = digest_of(document, element_id)
      signature = build_signature(element_id, digest, key, certificate)

      # The schema puts the signature immediately after the issuer.
      element.insert_after(REXML::XPath.first(element, "saml:Issuer", "saml" => ASSERTION_NS), signature)
    end

    # The enveloped-signature digest: the referenced subtree, canonicalized in
    # its document context, before any signature is added to it.
    def digest_of(document, element_id)
      node = XMLSecurity::BaseDocument.safe_load_xml(document.to_s)
                                      .at_xpath("//*[@ID=$id]", nil, { "id" => element_id })
      canonical = node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_prefixes)
      Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(canonical))
    end

    def build_signature(reference_id, digest, key, certificate)
      signature = REXML::Element.new("ds:Signature").add_namespace("ds", XMLSecurity::BaseDocument::DSIG)
      signed_info = signature.add_element("ds:SignedInfo")
      signed_info.add_element("ds:CanonicalizationMethod", "Algorithm" => XMLSecurity::BaseDocument::C14N)
      signed_info.add_element("ds:SignatureMethod", "Algorithm" => XMLSecurity::Document::RSA_SHA256)

      reference = signed_info.add_element("ds:Reference", "URI" => "##{reference_id}")
      transforms = reference.add_element("ds:Transforms")
      transforms.add_element("ds:Transform", "Algorithm" => XMLSecurity::Document::ENVELOPED_SIG)
      transforms.add_element("ds:Transform", "Algorithm" => XMLSecurity::BaseDocument::C14N)
                .add_element("ec:InclusiveNamespaces",
                             "xmlns:ec" => XMLSecurity::BaseDocument::C14N,
                             "PrefixList" => XMLSecurity::Document::INC_PREFIX_LIST)
      reference.add_element("ds:DigestMethod", "Algorithm" => XMLSecurity::Document::SHA256)
      reference.add_element("ds:DigestValue").text = digest

      signature.add_element("ds:SignatureValue").text = signed_info_signature(signature, key)
      signature.add_element("ds:KeyInfo")
               .add_element("ds:X509Data")
               .add_element("ds:X509Certificate").text = der_base64(certificate)
      signature
    end

    def signed_info_signature(signature, key)
      canonical = XMLSecurity::BaseDocument.safe_load_xml(signature.to_s)
                                           .at_xpath("//ds:SignedInfo", "ds" => XMLSecurity::BaseDocument::DSIG)
                                           .canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      Base64.strict_encode64(key.sign(OpenSSL::Digest.new("SHA256"), canonical))
    end

    def inclusive_prefixes = XMLSecurity::Document::INC_PREFIX_LIST.split

    def der_base64(certificate = self.certificate) = Base64.strict_encode64(certificate.to_der)

    def identifier = "_#{SecureRandom.uuid}"

    def timestamp(time) = time.utc.iso8601
  end
end
