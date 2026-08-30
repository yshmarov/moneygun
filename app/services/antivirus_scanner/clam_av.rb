# frozen_string_literal: true

module AntivirusScanner
  class ClamAv
    class LimitExceededError < StandardError; end
    class CommandFailedError < StandardError; end

    DATABASE_DIR = ENV.fetch("CLAMAV_DATABASE_DIR", "/var/lib/clamav")
    SCAN_TIMEOUT = ENV.fetch("CLAMAV_SCAN_TIMEOUT", 120).to_i
    LIMIT_ALERT_PATTERN = /Heuristics\.Limits\.Exceeded/i

    def initialize(command_runner: CommandRunner.new)
      @command_runner = command_runner
    end

    def available?
      system("which", "clamscan", out: File::NULL, err: File::NULL) &&
        Dir.glob(File.join(DATABASE_DIR, "{main,daily,bytecode}.{cvd,cld}")).any?
    end

    def scan(path)
      return Result.unavailable unless available?

      result = @command_runner.call(*scan_command(path), timeout: SCAN_TIMEOUT)
      return Result.error(LimitExceededError.new("ClamAV safety limit exceeded")) if result.output.match?(LIMIT_ALERT_PATTERN)

      case result.exit_status
      when 0 then Result.clean
      when 1 then Result.infected
      else Result.error(CommandFailedError.new("ClamAV exited without a verdict (status #{result.exit_status.inspect})"))
      end
    rescue CommandRunner::UnavailableError => e
      Result.unavailable(e)
    rescue CommandRunner::TimeoutError, CommandRunner::OutputLimitExceededError => e
      Result.error(e)
    end

    private

    def scan_command(path)
      [
        "clamscan", "--no-summary", "--stdout", "--alert-exceeds-max=yes",
        "--max-filesize=#{ENV.fetch('CLAMAV_MAX_FILE_SIZE', '100M')}",
        "--max-scansize=#{ENV.fetch('CLAMAV_MAX_SCAN_SIZE', '200M')}",
        "--max-files=#{ENV.fetch('CLAMAV_MAX_FILES', 1_000)}",
        "--max-recursion=#{ENV.fetch('CLAMAV_MAX_RECURSION', 10)}",
        "--database=#{DATABASE_DIR}", path
      ]
    end
  end
end
