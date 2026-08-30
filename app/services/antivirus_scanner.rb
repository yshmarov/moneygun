# frozen_string_literal: true

module AntivirusScanner
  RESULT_STATUSES = %i[clean infected unavailable error].freeze

  Result = Data.define(:status, :error) do
    def initialize(status:, error: nil)
      raise ArgumentError, "Unknown antivirus result: #{status}" unless RESULT_STATUSES.include?(status)

      super
    end

    def self.clean = new(status: :clean)
    def self.infected = new(status: :infected)
    def self.unavailable(error = nil) = new(status: :unavailable, error: error)
    def self.error(error = nil) = new(status: :error, error: error)
  end

  class << self
    attr_writer :client

    def client
      @client ||= ClamAv.new
    end
  end
end
