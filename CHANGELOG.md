# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Direct invitation links via Invitations#show page
- Cloudflared tunnel documentation
- Profile and notifications links to navigation

### Changed

- Replaced Fly.io, Render, and Heroku deployment with Kamal
- Renamed PageComponent to SectionComponent
- Increased SectionComponent max width to 2xl
- Use md size for SimpleForm inputs

### Removed

- Sign-in and authentication success toasts
- `created_at` column from organization table

### Security

- Updated faraday to 2.14.1 to fix SSRF vulnerability (CVE-2026-25765)

## [2026-01-23]

### Added

- Linear-inspired light and dark themes
- Essential tests for StripePrice and SubscriptionPolicy
- Git workflow rules to CLAUDE.md
- AI learnings to CLAUDE.md
- CLAUDE.md with project guidance for Claude Code

### Changed

- Simplified AccessRequest STI with template method pattern
- Replaced StripePriceService with StripePrice PORO
- Used Pundit for SubscriptionsController authorization
- Simplified default Stripe checkout settings
- Replaced DropdownPopoverComponent with CSS-only version
- Simplified pundit_user in OrganizationsController
- Redirect to organization dashboard after invitation acceptance
- Improved accessibility and empty state handling in views
- Consolidated documentation into docs/ folder

### Fixed

- Allow users to be re-invited after declining
- Inefficient participant? query
- MembershipPolicy#index to require membership
- Magic string in Membership model
- Notification error when organization is destroyed

### Security

- Enabled Pundit verify_authorized in base controller
- Restricted developer OAuth provider to development only
- Removed admin bypass in development for admin routes
- Added tokens to parameter filter list
- Sanitized markdown output while preserving embeds
- Updated production domain to use HOST environment variable

### Removed

- ruby_llm gem (not core for boilerplate)
- profitable gem
- nested_scaffold gem in favor of AI-based code generation

## [2026-01-06]

### Added

- Improved linting configuration

### Changed

- Refactored form builder variable from `form` to `f`
- Refactored membership system with directional naming for invitations and join requests

## [2025-12-24]

### Added

- Sidebar organization selector with daisyUI tree nav
- Search moved from navbar to sidebar

### Changed

- Updated daisyUI to latest version
- Refactored Devise layouts and improved OAuth divider
- Updated sign-in button text for clarity
