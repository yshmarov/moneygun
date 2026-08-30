# Agreement versions

The `agreements` gem owns current-version lookup, append-only acceptance evidence, stale-submission protection, and safe return paths. Moneygun owns its agreement keys, legal copy, routes, authorization, and UI.

The starter migration intentionally uses `https://example.com` document URLs. Replace those references with the application's final, externally hosted Terms, Privacy Notice, and DPA URLs before the migration reaches production. Never rewrite a version after it may have acceptances.

To require a later version, add it to `db/seeds/agreements.rb` for fresh databases and add an irreversible data migration with the same key, version, statement, and documents for deployed databases. Update the localized checkbox statement in the same release. Existing acceptances remain evidence for the old version and users are prompted for the new current version.
