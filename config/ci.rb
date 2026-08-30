# frozen_string_literal: true

# Run using bin/ci. This file owns the local suite; hosted CI calls the same
# commands so a local green result means the same checks actually ran.

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Lint & checks", "bin/lint"

  step "Security: Secret scan", "bin/gitleaks-audit"

  step "Website: Hugo build", "website/bin/check"

  step "Boot: Zeitwerk eager-load check", "env RAILS_ENV=test bin/rails zeitwerk:check"
  step "Database: Active Record Doctor", "env RAILS_ENV=test bin/rails db:test:prepare active_record_doctor"

  step "Tests: Rails", "env RAILS_ENV=test COVERAGE=true bin/rails test"
  step "Tests: System", "env RAILS_ENV=test bin/rails db:test:prepare test:system"
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"
end
