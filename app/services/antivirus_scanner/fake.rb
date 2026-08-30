# frozen_string_literal: true

module AntivirusScanner
  class Fake
    def initialize(status: :clean, error: nil)
      @result = Result.new(status: status, error: error)
    end

    def scan(_path)
      @result
    end
  end
end
