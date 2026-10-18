# frozen_string_literal: true

require "timeout"

class FileMetadataStripper
  class Error < StandardError; end

  CommandResult = Data.define(:status, :output)
  COMMAND_TIMEOUT = ENV.fetch("FILE_METADATA_STRIPPER_TIMEOUT", 30).to_i
  COMMAND_OUTPUT_LIMIT = 64.kilobytes
  IMAGE_EXTENSIONS = {
    "image/avif" => ".avif", "image/gif" => ".gif", "image/jpeg" => ".jpg",
    "image/png" => ".png", "image/webp" => ".webp"
  }.freeze
  IMAGE_LOADERS = {
    "image/avif" => :heifload,
    "image/gif" => :gifload,
    "image/jpeg" => :jpegload,
    "image/png" => :pngload,
    "image/webp" => :webpload
  }.freeze
  EXIFTOOL_EXTENSIONS = {
    "application/pdf" => ".pdf", "video/mp4" => ".mp4", "video/quicktime" => ".mov",
    "audio/mpeg" => ".mp3", "audio/mp4" => ".m4a"
  }.freeze
  EXIFTOOL_PRIVACY_TAGS = %w[
    -EXIF:all -XMP:all -IPTC:all -ID3:all -PDF:Author -PDF:Creator -PDF:Producer
    -QuickTime:GPSCoordinates -QuickTime:Location* -Keys:GPSCoordinates -Keys:Location*
    -UserData:GPSCoordinates -UserData:Location*
  ].freeze

  def self.strip!(file_path, declared_type)
    content_type = Marcel::MimeType.for(Pathname.new(file_path), declared_type: declared_type)

    if IMAGE_LOADERS.key?(content_type)
      strip_image!(file_path, content_type)
    elsif EXIFTOOL_EXTENSIONS.key?(content_type)
      strip_with_exiftool!(file_path, content_type)
    end
  end

  def self.strip_image!(file_path, content_type)
    image = load_image(file_path, content_type)
    validate_image_dimensions!(image)

    with_sanitized_tempfile(file_path, IMAGE_EXTENSIONS.fetch(content_type)) do |sanitized|
      image.write_to_file(sanitized.path, strip: true)
      verify_image!(sanitized.path, content_type, width: image.width, height: image.height)
      FileUtils.cp(sanitized.path, file_path)
    end
  rescue Vips::Error => e
    raise Error, "Image metadata could not be stripped", cause: e
  end

  def self.load_image(file_path, content_type)
    Vips::Image.public_send(IMAGE_LOADERS.fetch(content_type), file_path, access: :sequential)
  end

  def self.strip_with_exiftool!(file_path, content_type)
    raise Error, "ExifTool is unavailable" unless exiftool_available?

    with_sanitized_tempfile(file_path, EXIFTOOL_EXTENSIONS.fetch(content_type)) do |sanitized|
      FileUtils.cp(file_path, sanitized.path)
      stripped = run_command("exiftool", "-all=", "-overwrite_original", "-quiet", sanitized.path)
      raise Error, "ExifTool could not strip file metadata" unless stripped.status.success?

      drop_pdf_revisions!(sanitized.path) if content_type == "application/pdf"
      verify_exiftool_metadata!(sanitized.path)
      FileUtils.cp(sanitized.path, file_path)
    end
  end

  def self.drop_pdf_revisions!(file_path)
    raise Error, "qpdf is unavailable" unless qpdf_available?

    with_sanitized_tempfile(file_path, ".pdf") do |rewritten|
      result = run_command("qpdf", "--warning-exit-0", file_path, rewritten.path)
      raise Error, "qpdf could not rewrite the PDF" unless result.status.success?
      raise Error, "Earlier PDF revisions could not be verified as removed" unless revision_count(rewritten.path) == 1

      FileUtils.cp(rewritten.path, file_path)
    end
  end

  def self.revision_count(file_path, chunk_size: 1.megabyte)
    token = "startxref"
    count = 0
    carry = "".b

    File.open(file_path, "rb") do |file|
      while (chunk = file.read(chunk_size))
        window = carry + chunk
        count += window.scan(token).size
        carry = window.byteslice(-(token.bytesize - 1)..) || window
      end
    end
    count
  end

  def self.validate_image_dimensions!(image)
    return if image.width <= ActiveStorageSafety::MAX_IMAGE_DIMENSION && image.height <= ActiveStorageSafety::MAX_IMAGE_DIMENSION

    raise Error, "Image dimensions exceed the safe processing limit"
  end

  def self.verify_image!(file_path, content_type, width:, height:)
    image = load_image(file_path, content_type)
    raise Error, "Sanitized image dimensions changed" unless image.width == width && image.height == height
    raise Error, "Image metadata could not be verified as removed" if image.get_fields.grep(/\A(?:exif|iptc|xmp)(?:-|$)/i).any?
  end

  def self.verify_exiftool_metadata!(file_path)
    result = run_command("exiftool", "-s3", "-a", *EXIFTOOL_PRIVACY_TAGS, file_path, capture_output: true)
    raise Error, "ExifTool could not verify stripped metadata" unless result.status.success?
    raise Error, "File metadata could not be verified as removed" if result.output.present?
  end

  def self.with_sanitized_tempfile(file_path, extension)
    Tempfile.create(["metadata-sanitized", extension], File.dirname(file_path)) do |tempfile|
      tempfile.binmode
      tempfile.close
      yield tempfile
    end
  end

  def self.run_command(*command, capture_output: false, timeout: COMMAND_TIMEOUT)
    reader, writer = IO.pipe if capture_output
    destination = capture_output ? writer : File::NULL
    pid = Process.spawn(*command, out: destination, err: File::NULL, pgroup: true)
    writer&.close
    writer = nil
    output_reader = Thread.new { drain_output(reader) } if reader
    _completed_pid, status = Timeout.timeout(timeout) { Process.wait2(pid) }
    pid = nil
    output = output_reader ? output_reader.value : ""
    raise Error, "File metadata verification output exceeded the safe limit" if output.bytesize > COMMAND_OUTPUT_LIMIT

    CommandResult.new(status: status, output: output)
  rescue Timeout::Error
    terminate_process_group(pid)
    pid = nil
    raise Error, "File metadata processor timed out"
  rescue Errno::ENOENT => e
    raise Error, "File metadata processor is unavailable", cause: e
  ensure
    writer&.close
    reader&.close unless reader&.closed?
    terminate_process_group(pid) if pid
    output_reader&.join(1)
  end

  def self.drain_output(reader)
    output = +""
    loop do
      chunk = reader.readpartial(16.kilobytes)
      remaining = (COMMAND_OUTPUT_LIMIT + 1) - output.bytesize
      output << chunk.byteslice(0, remaining) if remaining.positive?
    end
  rescue IOError
    output
  end

  def self.terminate_process_group(pid)
    return unless pid

    Process.kill("KILL", -pid)
    Process.wait(pid)
  rescue Errno::ESRCH, Errno::ECHILD
    nil
  end

  def self.exiftool_available?
    return @exiftool_available if defined?(@exiftool_available)

    @exiftool_available = system("which", "exiftool", out: File::NULL, err: File::NULL) == true
  end

  def self.qpdf_available?
    return @qpdf_available if defined?(@qpdf_available)

    @qpdf_available = system("which", "qpdf", out: File::NULL, err: File::NULL) == true
  end
end
