# frozen_string_literal: true

ActiveRecordDoctor.configure do
  framework_tables = [
    "schema_migrations",
    /^action_mailbox_/,
    /^action_text_/,
    /^active_storage_/,
    /^good_job/,
    /^nondisposable_/,
    /^noticed_/,
    /^pay_/,
    /^refer_/,
    /^solid_/
  ]

  framework_models = [
    /^ActionMailbox::/,
    /^ActionText::/,
    /^ActiveStorage::/,
    /^GoodJob::/,
    /^Nondisposable::/,
    /^Noticed::/,
    /^Pay::/,
    /^Refer::/,
    /^Solid/
  ]

  global :ignore_tables, framework_tables
  global :ignore_models, framework_models

  detector :extraneous_indexes, enabled: false
  detector :incorrect_dependent_option, enabled: false
  detector :incorrect_length_validation, ignore_attributes: ["User.name"]
  detector :missing_presence_validation, enabled: false
end
