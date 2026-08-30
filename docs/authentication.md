# Authentication

Moneygun uses passwordless email codes backed by first-party `Session` and `MagicLink` models. It does not depend on Devise, passwords, or consumer OAuth providers.

## Sign-in flow

1. A visitor submits an email address.
2. Moneygun creates a six-digit, 15-minute `MagicLink` code and emails it.
3. Consuming the latest valid code verifies the address and creates a database-backed session.
4. If TOTP is enabled, a five-minute pending token moves the visitor through the second-factor screen before a session is created.

Responses do not reveal whether an address already exists. Session cookies are HTTP-only and SameSite=Lax, and sessions expire after 14 days of inactivity.

## Sensitive actions

`require_sudo(:reason)` requires authentication within the last 30 minutes. Users with TOTP confirm using their authenticator; other users receive a purpose-scoped email code. Organization deletion, ownership transfer, email changes, MFA setup, and enterprise identity settings use this boundary.

## Two-factor authentication

`User::TwoFactor` supports standard six-digit TOTP plus ten one-time backup codes. Secrets and backup codes use Active Record Encryption with purpose-separated keys derived from the application's secret key base. A backup code is atomically removed when used.

## Email changes and sessions

Changing an email address requires sudo authentication and a code delivered to the new address. Successful verification revokes every other active session.

## SSO enforcement

When an enabled SAML connection enforces a verified email domain, email-code sign-in for that domain is refused and the visitor is sent through SSO discovery. See [Enterprise identity](enterprise-identity.md).
