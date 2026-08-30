# frozen_string_literal: true

require "timeout"

module AntivirusScanner
  class CommandRunner
    class TimeoutError < StandardError; end
    class UnavailableError < StandardError; end
    class OutputLimitExceededError < StandardError; end

    Result = Data.define(:exit_status, :output)
    OUTPUT_LIMIT = 64.kilobytes

    def call(*command, timeout:)
      raise ArgumentError, "timeout must be positive" unless timeout.positive?

      reader, writer = IO.pipe
      pid = Process.spawn(*command, out: writer, err: writer, pgroup: true)
      writer.close

      Timeout.timeout(timeout) do
        output = read_output(reader)
        _completed_pid, status = Process.wait2(pid)
        pid = nil
        Result.new(exit_status: status.exitstatus, output: output)
      end
    rescue Timeout::Error
      terminate_process_group(pid)
      pid = nil
      raise TimeoutError, "Antivirus scan timed out"
    rescue Errno::ENOENT, Errno::EACCES => e
      raise UnavailableError, "Antivirus scanner is unavailable", cause: e
    ensure
      writer&.close unless writer&.closed?
      reader&.close unless reader&.closed?
      terminate_process_group(pid) if pid
    end

    private

    def read_output(reader)
      output = +"".b
      loop do
        output << reader.readpartial([16.kilobytes, OUTPUT_LIMIT + 1 - output.bytesize].min)
        raise OutputLimitExceededError, "Antivirus output exceeded the safe limit" if output.bytesize > OUTPUT_LIMIT
      rescue EOFError
        return output
      end
    end

    def terminate_process_group(pid)
      return unless pid

      Process.kill("KILL", -pid)
    rescue Errno::ESRCH
      nil
    ensure
      reap_process(pid)
    end

    def reap_process(pid)
      Process.wait(pid)
    rescue Errno::ECHILD
      nil
    end
  end
end
