# frozen_string_literal: true

require "open3"

class ClamavUpdateJob < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform
    raise "freshclam not installed" unless system("which", "freshclam", out: File::NULL, err: File::NULL)

    output, status = Open3.capture2e("freshclam", "--quiet")
    raise "[ClamAV] freshclam failed: #{output.strip}" unless status.success?
  end
end
