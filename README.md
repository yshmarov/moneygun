# Moneygun - Simple Rails 8 SaaS Boilerplate

A production-ready Ruby on Rails boilerplate for building multi-tenant SaaS applications. Built with best practices, modern tooling, and a focus on developer experience.

[![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-8.1.0-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🚀 Features

### Core Functionality

- **Multi-tenant Architecture**: Route-based organization management
- **Authentication & Authorization**: Built with Devise and Pundit
- **Subscription Management**: Integrated Stripe payments via Pay gem
- **Team Management**: Organization creation, member invitations, and role management
- **Modern UI**: Clean, responsive design that you can easily extend

### Developer Experience

- **Complete Test Coverage**
- **Nested Resource Generation**: Fast development with nested scaffold generators

## 🎯 Why Moneygun?

### Route-Based Multi-tenancy

Unlike traditional approaches (subdomains, user.organization_id), Moneygun uses route-based multi-tenancy which offers several advantages:

- Support for multiple organizations in different browser tabs
- No complex subdomain configuration required

### Resource Organization

Resources are organized in a logical hierarchy:

```ruby
/organizations/:id/projects/:id/tasks/:id
```

This structure provides:

- Clear resource ownership
- Intuitive navigation
- Easy access control
- Simplified querying

## 🛠️ Getting Started

1. Clone the repository:

```bash
git clone git@github.com:yshmarov/moneygun.git your_project_name
cd your_project_name
```

2. Set up the application:

```bash
bundle install
rails db:create db:migrate
```

3. Start the development server:

```bash
bin/dev
```

## 📚 Development Guide

### Resource Generation

Generate nested resources quickly using the nested_scaffold gem:

```bash
rails generate nested_scaffold organization/project name
```

### Authorization

Generate Pundit policies for your resources:

```bash
rails g pundit:policy project
```

### Best Practices

#### Resource Associations

Always associate resources with `membership` instead of `user`:

```ruby
# ✅ Correct
class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :membership
end

# ❌ Avoid
class Project < ApplicationRecord
  belongs_to :user
end
```

#### Organization Scoping

Scope downstream models to organization for easier querying:

```ruby
class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project
end
```

## 🧪 Testing

Run the test suite:

```bash
rails test:all
```

### Code Quality

```bash
# ERB linting
bundle exec erb_lint --lint-all -a

# Ruby linting
bundle exec rubocop -A
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Design inspiration from Basecamp, Trello, Discord, and Slack
