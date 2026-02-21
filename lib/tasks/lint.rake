# frozen_string_literal: true

desc "Run all linters with autocorrect"
task lint: :environment do
  sh "bin/rubocop -A"
  sh "bin/erb_lint --lint-all -a"
  sh "npx prettier --write ."
end
