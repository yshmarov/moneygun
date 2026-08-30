# frozen_string_literal: true

# config/allgood.rb

deployed_revision = lambda do
  ENV["APP_REVISION"].presence || ENV["APPSIGNAL_APP_REVISION"].presence || ENV["KAMAL_VERSION"].presence ||
    (Rails.root.join("REVISION").read.strip if Rails.root.join("REVISION").exist?).presence
end

good_job_count = ->(sql) { ActiveRecord::Base.connection.select_value(sql).to_i }
last_cron_success_at = lambda do |job_class|
  ActiveRecord::Base.connection.select_value(<<~SQL.squish)
    SELECT MAX(finished_at) FROM good_jobs
    WHERE serialized_params->>'job_class' = '#{job_class}' AND error IS NULL
  SQL
end

check "We have an active database connection" do
  make_sure ActiveRecord::Base.connection.connect!.active?
end

check "Database can perform a simple query" do
  make_sure ActiveRecord::Base.connection.execute("SELECT 1").any?
end

check "Database migrations are up to date" do
  make_sure ActiveRecord::Migration.check_all_pending!.nil?
end

check "Disk space usage is below 90%" do
  usage = `df -h / | tail -1 | awk '{print $5}' | sed 's/%//'`.to_i
  expect(usage).to_be_less_than(90)
end

check "Memory usage is below 90%" do
  usage = `free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1`.to_i
  expect(usage).to_be_less_than(90)
end

check "ClamAV virus scanner is installed" do
  make_sure system("which", "clamscan", out: File::NULL, err: File::NULL), "clamscan binary not found"
end

check "ClamAV signatures were refreshed in the past 25 hours", only: :production do
  refreshed_at = last_cron_success_at.call("ClamavUpdateJob")
  make_sure refreshed_at.present? && refreshed_at.to_time > 25.hours.ago, "ClamAV signatures are stale or missing"
end

check "Cache is accessible and functioning" do
  Rails.cache.write("allgood_test", "ok")
  make_sure Rails.cache.read("allgood_test") == "ok", "The `allgood_test` key in the cache should contain `'ok'`"
end

check "Application revision is available", only: :production do
  make_sure deployed_revision.call.present?, "No deployed revision found"
end

check "AppSignal error reporting is active", only: :production do
  make_sure defined?(Appsignal) && !Appsignal.config_error? && Appsignal.active?, "AppSignal is not active"
end

check "GoodJob tables are accessible" do
  make_sure ActiveRecord::Base.connection.data_source_exists?("good_jobs") &&
            ActiveRecord::Base.connection.data_source_exists?("good_job_processes")
end

check "GoodJob has a recent worker heartbeat", only: :production do
  recent = good_job_count.call(<<~SQL.squish)
    SELECT COUNT(*) FROM good_job_processes
    WHERE updated_at > #{ActiveRecord::Base.connection.quote(10.minutes.ago)}
  SQL
  expect(recent).to_be_greater_than(0)
end

check "GoodJob has no failed jobs in the past 24 hours" do
  failures = good_job_count.call(<<~SQL.squish)
    SELECT COUNT(*) FROM good_jobs
    WHERE error IS NOT NULL AND created_at > #{ActiveRecord::Base.connection.quote(24.hours.ago)}
  SQL
  expect(failures).to_eq(0)
end

check "Active Storage can write, read, and delete", run: "6 times per hour" do
  key = "allgood/#{SecureRandom.uuid}.txt"
  ActiveStorage::Blob.service.upload(key, StringIO.new("ok"), checksum: Digest::MD5.base64digest("ok"))
  make_sure ActiveStorage::Blob.service.download(key) == "ok"
ensure
  ActiveStorage::Blob.service.delete(key) if key
end

check "Mail delivery is configured", only: :production do
  make_sure ActionMailer::Base.perform_deliveries, "Action Mailer deliveries are disabled"
  make_sure ActionMailer::Base.delivery_method == :smtp, "SMTP delivery is not configured"
end
