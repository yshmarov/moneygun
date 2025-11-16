# frozen_string_literal: true

# config/allgood.rb

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

check "Cache is accessible and functioning" do
  Rails.cache.write("allgood_test", "ok")
  make_sure Rails.cache.read("allgood_test") == "ok", "The `allgood_test` key in the cache should contain `'ok'`"
end
