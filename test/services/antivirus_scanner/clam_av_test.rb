# frozen_string_literal: true

require "test_helper"

class AntivirusScanner::ClamAvTest < ActiveSupport::TestCase
  setup do
    @runner = mock
    @scanner = AntivirusScanner::ClamAv.new(command_runner: @runner)
    @scanner.stubs(:available?).returns(true)
  end

  test "maps only the documented verdict exit statuses" do
    @runner.stubs(:call).returns(AntivirusScanner::CommandRunner::Result.new(exit_status: 0, output: ""))
    assert_equal :clean, @scanner.scan("/tmp/file").status

    @runner.stubs(:call).returns(AntivirusScanner::CommandRunner::Result.new(exit_status: 1, output: "EICAR FOUND"))
    assert_equal :infected, @scanner.scan("/tmp/file").status

    @runner.stubs(:call).returns(AntivirusScanner::CommandRunner::Result.new(exit_status: 2, output: ""))
    assert_equal :error, @scanner.scan("/tmp/file").status
  end

  test "treats safety limit alerts as errors, not infections" do
    @runner.stubs(:call).returns(
      AntivirusScanner::CommandRunner::Result.new(exit_status: 1, output: "Heuristics.Limits.Exceeded.MaxScanSize FOUND")
    )

    assert_instance_of AntivirusScanner::ClamAv::LimitExceededError, @scanner.scan("/tmp/file").error
  end

  test "bounds archive expansion" do
    command = @scanner.send(:scan_command, "/tmp/file")

    assert_includes command, "--alert-exceeds-max=yes"
    assert_includes command, "--max-filesize=100M"
    assert_includes command, "--max-scansize=200M"
    assert_includes command, "--max-recursion=10"
  end
end
