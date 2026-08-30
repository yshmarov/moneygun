# frozen_string_literal: true

module MagicLink::Code
  DIGITS = ("0".."9").to_a.freeze

  class << self
    def generate(length)
      Array.new(length) { DIGITS[SecureRandom.random_number(DIGITS.size)] }.join
    end

    def sanitize(code)
      return if code.blank?

      code.to_s.gsub(/\D/, "")
    end
  end
end
