# Migration baseline

`db/schema.rb` is the source for creating a new Moneygun database. The historical migration chain was removed after the schema was consolidated on 2026-08-30.

Continue to generate and commit normal forward migrations for every schema or deployed-data change, together with the resulting `db/schema.rb` update. Those migrations must remain until every maintained deployment has applied them and a later deliberate squash establishes a new schema baseline.

Do not reconstruct a new installation by replaying migrations and do not edit `db/schema.rb` by hand. Use `bin/rails db:prepare` or `bin/rails db:schema:load`.
