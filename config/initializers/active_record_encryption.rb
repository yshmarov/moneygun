# frozen_string_literal: true

encryption = Rails.application.config.active_record.encryption
key_generator = Rails.application.key_generator

encryption.primary_key ||= key_generator.generate_key("active-record-encryption-primary-key", 32)
encryption.deterministic_key ||= key_generator.generate_key("active-record-encryption-deterministic-key", 32)
encryption.key_derivation_salt ||= key_generator.generate_key("active-record-encryption-key-derivation-salt", 32)
