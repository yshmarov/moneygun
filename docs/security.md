# Security model

## Tenant isolation

Organization resources are loaded through `@organization` or `Current.organization`; policies receive `Current.membership`. Models that carry both `organization` and `membership` validate that the associations belong to the same tenant. Deactivated memberships are excluded from tenant lookup.

## Audit trail

`AuditLog` stores tenant-scoped, namespaced events with actor and request snapshots. Audit rows are append-only in both Active Record and PostgreSQL; organization deletion intentionally removes that tenant's audit rows through the foreign key cascade.

Applications can add actions without editing a central enum:

```ruby
AuditLog.log!(
  organization: Current.organization,
  mini_app: "invoicing",
  action: "invoice.sent",
  actor: Current.membership,
  actor_kind: Current.audit_actor_kind,
  subject: invoice
)
```

For routine model updates, include `Auditable` and declare the fields that carry useful business history. The concern records meaningful committed changes and keeps controller code out of the audit path:

```ruby
class Project < ApplicationRecord
  include Auditable

  audits :name, :status
end
```

Use `AuditLog.log!` directly for actions that are not naturally represented by one model update, such as authentication, invitations, or exports.

## File authorization

Signed Active Storage URLs are locators, not authorization. Moneygun checks every blob and representation request against its attached record:

- project files require an active membership in the owning organization;
- explicit public assets such as user avatars and organization logos remain public;
- unattached blobs are denied;
- direct-upload creation requires an authenticated session and is rate-limited.

New attachment-owning models must implement `active_storage_accessible_to?(user)` or explicitly opt into public access with `active_storage_publicly_accessible?`.

Avatar and logo variants are preprocessed after the attachment commit so the first page render does not pay image-processing latency. Attachment change tracking happens during `after_save`; only the background-job enqueue happens after commit.

SVG UI icons are external, cacheable files rendered through `icon_tag` and CSS masks. Every SVG needs an XML namespace. Keep multicolor brand marks as `image_tag` assets instead of converting them to masks or inlining them.

## Browser boundary

Production responses enforce Content Security Policy and Permissions Policy. CSP uses per-request script nonces, denies object embedding, restricts framing, and reports violations to `/csp-reports`. The reporting endpoint records only a fixed set of safe browser fields, never the full submitted document.

SAML handoff responses extend `form-action` only for the selected identity provider URL. New third-party scripts, frames, API connections, or form destinations must be added narrowly to `config/initializers/content_security_policy.rb`; do not weaken the global policy to make one integration work.

## Operational checks

Run `bin/lint` for RuboCop, Brakeman, ERB, i18n, dependency, and import-map checks. `bin/ci` also runs Gitleaks against the current working tree and commit range. Run `bin/rails test:all` for the complete Rails suite. Secrets and generated enterprise tokens must never be committed.

`MaintenanceJob` runs hourly through GoodJob to remove expired sessions, codes, SAML requests, old invitations, and unattached direct-upload blobs.

`bin/security-audit` performs a read-only production host, container, database, and application anomaly sweep. It fails closed: an unavailable source is `UNVERIFIED` and produces a non-zero exit. Configure generic installations with `KAMAL_HOST`, `KAMAL_SERVICE`, `POSTGRES_USER`, and `POSTGRES_DB`; use `KNOWN_SSH_KEYS` to flag unexpected login keys.

`TARGET=https://app.example.com ruby script/security/recon.rb` performs a passive GET-only external scan for missing security headers, information disclosure, insecure cookies, and anonymously exposed sensitive paths. It exits non-zero on findings or collection failures. Use `ALLOW_HTTP=1` only for an intentional local-development scan.
