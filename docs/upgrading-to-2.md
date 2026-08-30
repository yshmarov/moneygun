# Upgrading an existing Moneygun application

Moneygun 2 replaces Devise/password/OAuth authentication and the old invitation STI flow. Treat the upgrade as an application migration, not a blind file copy.

1. Back up the database and rehearse against production-shaped data.
2. Deploy the additive passwordless/session and invitation migrations first. Existing confirmed users are marked email-verified, and pending organization invitations are backfilled.
3. Verify email-code sign-in, invitation acceptance, active sessions, tenant access, and rollback procedures in staging.
4. Deploy the code cutover that removes Devise and OAuth entry points.
5. Only after that verification, apply the legacy-auth cleanup migration that removes password, Devise Invitable, and identity-provider columns/tables.
6. Configure SAML/SCIM only after the core authentication cutover is stable. Verify domains before enabling enforcement.

If your fork has custom OAuth identities or password-dependent integrations, preserve those tables and adapt the cutover rather than applying the cleanup migration unchanged.
