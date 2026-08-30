# frozen_string_literal: true

module ActiveStorage
  class Analyzer::SafeImageAnalyzer < Analyzer::ImageAnalyzer::Vips
    def metadata
      read_image do |image|
        width = image.width
        height = image.height

        if width > ActiveStorageSafety::MAX_IMAGE_DIMENSION || height > ActiveStorageSafety::MAX_IMAGE_DIMENSION
          logger.warn "[SafeImageAnalyzer] Image too large: #{width}x#{height}"
          return { width: width, height: height, safe: false }
        end

        { width: width, height: height }
      end
    end
  end
end
