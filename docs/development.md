# Development Guide

## Commands

### Server

```bash
bin/dev    # Start all services (web, css, stripe, jobs)
```

### Testing

```bash
rails test           # Run unit/integration tests
rails test:system    # Run system tests
rails test:all       # Run all tests
```

Run specific tests:

```bash
rails test test/models/user_test.rb      # Single file
rails test test/models/user_test.rb:42   # Specific line
```

### Database

```bash
rails db:migrate    # Run migrations
rails db:rollback   # Rollback last migration
rails db:seed       # Seed data
rails db:reset      # Drop, create, migrate, seed
```

## Code Quality

### Linting

```bash
# Ruby
bundle exec rubocop        # Check
bundle exec rubocop -A     # Auto-fix

# ERB templates
bundle exec erb_lint --lint-all      # Check
bundle exec erb_lint --lint-all -a   # Auto-fix

# i18n keys
i18n-tasks normalize       # Sort alphabetically
```

See [Linting](linting.md) for detailed configuration.

### Formatting

```bash
npx prettier --check .     # Check formatting
npx prettier --write .     # Auto-format
```

## Adding Features

### New Organization-Scoped Resource

1. **Create the model and migration:**

   ```ruby
   class Task < ApplicationRecord
     belongs_to :organization
     belongs_to :membership
   end
   ```

2. **Add the route** in `config/routes/organizations.rb`:

   ```ruby
   resources :tasks
   ```

3. **Create the controller** inheriting from `Organizations::BaseController`:

   ```ruby
   class Organizations::TasksController < Organizations::BaseController
     def index
       authorize Task
       @tasks = @organization.tasks
     end
   end
   ```

4. **Add Pundit policy:**

   ```bash
   rails g pundit:policy task
   ```

5. **Write tests**

### Subscription-Protected Feature

Add `before_action :require_subscription` to the controller:

```ruby
class Organizations::PremiumController < Organizations::BaseController
  before_action :require_subscription
end
```

## Coding Conventions

- **Thin controllers, rich models** - Business logic belongs in models
- **Use Current context** - Access `Current.organization`, `Current.membership`
- **Scope to organization** - Never query resources without organization scope
- **Pundit uses membership** - `pundit_user` returns `Current.membership`
- **Obfuscated IDs** - Use `ObfuscatesId` concern for public-facing resources

## CI/CD

GitHub Actions runs on every push and pull request:

- RuboCop (Ruby linting)
- erb_lint (ERB linting)
- Test suite

All checks must pass before merging.
