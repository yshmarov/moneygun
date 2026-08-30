# Enterprise identity

Moneygun includes per-organization SAML 2.0 SSO and SCIM 2.0 provisioning. Both are tenant-bound and protected by recent-authentication checks in the settings UI.

Organization owners configure connections in the tenant UI. Avo exposes read-only SSO and SCIM resources for support diagnosis, including connection state and recent activity, without turning the global admin into a second configuration surface.

## SAML SSO

Configure an IdP entity ID, SSO URL, and signing certificate under the organization's Single sign-on page. Claim an email domain, publish the shown DNS TXT record, verify it, then enable the connection.

Security properties:

- only verified domains participate in discovery or enforcement;
- assertions must be signed and match the service-provider audience;
- each SP-initiated AuthnRequest is stored server-side and consumed once;
- the connection is carried in a short-lived encrypted cross-site flow cookie;
- JIT can create a brand-new identity or reactivate a former member, but cannot adopt a pre-existing global account that has no prior relationship with the tenant;
- application TOTP still runs after the SAML assertion.

The ACS URL is `/auth/saml/callback`; metadata is available at `/auth/saml/metadata`.

## SCIM provisioning

Generate a bearer token under the organization's SCIM provisioning page and configure the IdP with `/scim/v2` as its base URL. The plaintext token is shown once; only its SHA-256 digest and last four characters are stored.

SCIM maps users to organization memberships. It can create, reactivate, rename within that organization's directory, and deactivate members. It cannot deactivate the owner or the only administrator. A pre-existing global account must accept an invitation before the tenant may provision it, preventing one tenant's IdP from adopting another tenant's identity.

Rotate a token from the settings page whenever its custody changes. Disabling a connection immediately rejects its token.
