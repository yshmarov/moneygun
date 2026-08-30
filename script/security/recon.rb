#!/usr/bin/env ruby
# frozen_string_literal: true

# Passive GET-only external scan. Production expects HTTPS security headers;
# set ALLOW_HTTP=1 when intentionally scanning local development.
require "net/http"
require "uri"

if ARGV.include?("--help")
  puts "Usage: TARGET=https://app.example.com ruby script/security/recon.rb"
  puts "Optional: SENSITIVE_PATHS=/admin,/.env ALLOW_HTTP=1"
  exit
end

target = ENV.fetch("TARGET", "http://localhost:3000")
security_headers = %w[strict-transport-security content-security-policy x-frame-options x-content-type-options referrer-policy permissions-policy]
leaky_headers = %w[x-runtime x-powered-by server]
sensitive_paths = ENV.fetch("SENSITIVE_PATHS", "/admin,/admin/jobs,/admin/pghero,/avo,/rails/info/routes,/.env,/config/database.yml,/.git/config,/sidekiq").split(",")
findings = 0

def fetch(target, path)
  uri = URI.join(target, path)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  http.open_timeout = http.read_timeout = 15
  http.request(Net::HTTP::Get.new(uri))
rescue StandardError => e
  warn "ERROR #{path}: #{e.class}: #{e.message}"
  nil
end

uri = URI(target)
unless %w[http https].include?(uri.scheme) && uri.host
  warn "TARGET must be an absolute HTTP(S) URL"
  exit 64
end

puts "== target: #{target} =="
root = fetch(target, "/")
exit 1 unless root

puts "\n[security headers]"
security_headers.each do |header|
  next if header == "strict-transport-security" && uri.scheme == "http" && ENV["ALLOW_HTTP"] == "1"

  present = !root[header].to_s.empty?
  findings += 1 unless present
  puts "  #{present ? 'OK' : 'MISSING'} #{header}"
end

puts "\n[information disclosure]"
leaky_headers.each do |header|
  value = root[header]
  findings += 1 if value
  puts "  #{value ? "LEAK #{header}: #{value}" : "OK #{header}"}"
end

if (cookie = root["set-cookie"])
  missing = %w[secure httponly samesite].reject { |flag| cookie.downcase.include?(flag) }
  missing.delete("secure") if uri.scheme == "http" && ENV["ALLOW_HTTP"] == "1"
  findings += missing.length
  puts "\n[session cookie] #{missing.empty? ? 'OK' : "MISSING #{missing.join(', ')}"}"
end

puts "\n[sensitive paths]"
sensitive_paths.each do |path|
  response = fetch(target, path)
  unless response
    findings += 1
    next
  end
  exposed = response.code == "200"
  findings += 1 if exposed
  puts "  #{response.code} #{exposed ? 'EXPOSED' : 'OK'} #{path}"
end

puts "\n#{findings.zero? ? 'PASS' : "FAIL: #{findings} finding(s)"}"
exit(findings.zero? ? 0 : 1)
