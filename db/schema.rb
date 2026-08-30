# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_30_130200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "access_requests", force: :cascade do |t|
    t.bigint "completed_by"
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.string "status", default: "pending", null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["completed_by"], name: "index_access_requests_on_completed_by"
    t.index ["organization_id"], name: "index_access_requests_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_access_requests_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_access_requests_on_user_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_analytics_browsers_per_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "name", null: false
    t.string "site", null: false
    t.bigint "total", default: 1, null: false
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["date", "site", "name", "version"], name: "idx_on_date_site_name_version_eeccd0371c"
  end

  create_table "active_analytics_views_per_days", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.date "date", null: false
    t.string "page", null: false
    t.string "referrer_host"
    t.string "referrer_path"
    t.string "site", null: false
    t.bigint "total", default: 1, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["date", "site", "page"], name: "index_active_analytics_views_per_days_on_date_and_site_and_page"
    t.index ["date", "site", "referrer_host", "referrer_path"], name: "index_views_per_days_on_date_site_referrer_host_referrer_path"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agreements_acceptances", force: :cascade do |t|
    t.text "acceptance_statement", null: false
    t.datetime "accepted_at", null: false
    t.string "actor_key", null: false
    t.bigint "agreement_version_id", null: false
    t.string "authority", null: false
    t.datetime "created_at", null: false
    t.string "locale", null: false
    t.string "subject_key", null: false
    t.datetime "updated_at", null: false
    t.index ["agreement_version_id", "subject_key"], name: "index_agreement_acceptances_on_version_and_subject", unique: true
    t.index ["subject_key"], name: "index_agreements_acceptances_on_subject_key"
  end

  create_table "agreements_versions", force: :cascade do |t|
    t.text "acceptance_statement", null: false
    t.string "agreement_key", null: false
    t.datetime "created_at", null: false
    t.json "documents", default: [], null: false
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["agreement_key", "version"], name: "index_agreements_versions_on_agreement_key_and_version", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id"
    t.string "actor_kind", null: false
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "mini_app", default: "organization", null: false
    t.bigint "organization_id"
    t.bigint "subject_id"
    t.string "subject_type"
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_audit_logs_on_actor"
    t.index ["mini_app"], name: "index_audit_logs_on_mini_app"
    t.index ["organization_id", "created_at"], name: "index_audit_logs_on_organization_id_and_created_at"
    t.index ["subject_type", "subject_id"], name: "index_audit_logs_on_subject_type_and_subject_id"
  end

  create_table "data_exports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "membership_id", null: false
    t.bigint "organization_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_data_exports_on_membership_id"
    t.index ["organization_id"], name: "index_data_exports_on_organization_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.bigint "invited_by_id"
    t.datetime "last_sent_at"
    t.bigint "organization_id", null: false
    t.string "role", default: "member", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_invitations_on_lower_email"
    t.index ["expires_at"], name: "index_invitations_on_expires_at"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["organization_id", "email"], name: "index_invitations_on_organization_id_and_email", unique: true
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "magic_links", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "new_email"
    t.string "purpose", default: "sign_in", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["code"], name: "index_magic_links_on_code", unique: true
    t.index ["expires_at"], name: "index_magic_links_on_expires_at"
    t.index ["user_id"], name: "index_magic_links_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.string "display_name"
    t.bigint "organization_id", null: false
    t.string "provisioned_via", default: "invitation", null: false
    t.string "role", default: "member", null: false
    t.string "scim_external_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id", "deactivated_at"], name: "index_memberships_on_organization_id_and_deactivated_at"
    t.index ["organization_id", "scim_external_id"], name: "index_memberships_on_organization_id_and_scim_external_id", unique: true, where: "(scim_external_id IS NOT NULL)"
    t.index ["organization_id", "user_id"], name: "index_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["role"], name: "index_memberships_on_role"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "nondisposable_disposable_domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_nondisposable_disposable_domains_on_name", unique: true
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.jsonb "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "organizations", force: :cascade do |t|
    t.boolean "admin_granted_access", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.string "privacy_setting", default: "private", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at", where: "(deleted_at IS NOT NULL)"
    t.index ["name"], name: "index_organizations_on_name", where: "(deleted_at IS NULL)"
    t.index ["owner_id"], name: "index_organizations_on_owner_id", where: "(deleted_at IS NULL)"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "amount_refunded"
    t.integer "application_fee_amount"
    t.datetime "created_at", null: false
    t.string "currency"
    t.bigint "customer_id", null: false
    t.jsonb "data"
    t.jsonb "metadata"
    t.string "processor_id", null: false
    t.string "stripe_account"
    t.bigint "subscription_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
    t.index ["subscription_id"], name: "index_pay_charges_on_subscription_id"
  end

  create_table "pay_customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.datetime "deleted_at", precision: nil
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor", null: false
    t.string "processor_id"
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "deleted_at"], name: "pay_customer_owner_index", unique: true
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id", unique: true
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor", null: false
    t.string "processor_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.jsonb "data"
    t.boolean "default"
    t.string "payment_method_type"
    t.string "processor_id", null: false
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", force: :cascade do |t|
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "current_period_end", precision: nil
    t.datetime "current_period_start", precision: nil
    t.bigint "customer_id", null: false
    t.jsonb "data"
    t.datetime "ends_at", precision: nil
    t.jsonb "metadata"
    t.boolean "metered"
    t.string "name", null: false
    t.string "pause_behavior"
    t.datetime "pause_resumes_at", precision: nil
    t.datetime "pause_starts_at", precision: nil
    t.string "payment_method_id"
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", null: false
    t.string "stripe_account"
    t.datetime "trial_ends_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "event"
    t.string "event_type"
    t.string "processor"
    t.datetime "updated_at", null: false
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.text "database"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.text "user"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.datetime "captured_at", precision: nil
    t.text "database"
    t.text "relation"
    t.text "schema"
    t.bigint "size"
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "projects", force: :cascade do |t|
    t.decimal "budget", precision: 10, scale: 2
    t.string "category"
    t.string "color"
    t.integer "completion_percentage"
    t.string "contact_email"
    t.decimal "cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.boolean "is_active", default: true
    t.bigint "membership_id", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.string "phone_number"
    t.decimal "price", precision: 10, scale: 2
    t.string "priority", default: "medium"
    t.datetime "scheduled_at"
    t.string "search_keywords"
    t.string "secret_token"
    t.date "start_date"
    t.time "start_time"
    t.string "status", default: "planning"
    t.text "tags", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["membership_id"], name: "index_projects_on_membership_id"
    t.index ["name", "organization_id"], name: "index_projects_on_name_and_organization_id", unique: true
    t.index ["organization_id"], name: "index_projects_on_organization_id"
  end

  create_table "refer_referral_codes", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "referrals_count", default: 0
    t.bigint "referrer_id", null: false
    t.string "referrer_type", null: false
    t.datetime "updated_at", null: false
    t.integer "visits_count", default: 0
    t.index ["code"], name: "index_refer_referral_codes_on_code", unique: true
    t.index ["referrer_type", "referrer_id"], name: "index_refer_referral_codes_on_referrer"
  end

  create_table "refer_referrals", force: :cascade do |t|
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.bigint "referee_id", null: false
    t.string "referee_type", null: false
    t.bigint "referral_code_id"
    t.bigint "referrer_id", null: false
    t.string "referrer_type", null: false
    t.datetime "updated_at", null: false
    t.index ["referee_type", "referee_id"], name: "index_refer_referrals_on_referee"
    t.index ["referral_code_id"], name: "index_refer_referrals_on_referral_code_id"
    t.index ["referrer_type", "referrer_id"], name: "index_refer_referrals_on_referrer"
  end

  create_table "refer_visits", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip"
    t.bigint "referral_code_id", null: false
    t.text "referrer"
    t.string "referring_domain"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.index ["referral_code_id"], name: "index_refer_visits_on_referral_code_id"
  end

  create_table "saml_auth_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "request_id", null: false
    t.bigint "sso_connection_id", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_saml_auth_requests_on_expires_at"
    t.index ["request_id"], name: "index_saml_auth_requests_on_request_id", unique: true
    t.index ["sso_connection_id"], name: "index_saml_auth_requests_on_sso_connection_id"
  end

  create_table "scim_connections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_membership_role", default: "member", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "last_request_at"
    t.bigint "organization_id", null: false
    t.string "token_digest", null: false
    t.string "token_last_four"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_scim_connections_on_organization_id", unique: true
    t.index ["token_digest"], name: "index_scim_connections_on_token_digest", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.jsonb "authentication", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "last_seen_at"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "sso_connections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_membership_role", default: "member", null: false
    t.boolean "enabled", default: false, null: false
    t.boolean "enforced", default: false, null: false
    t.text "idp_cert"
    t.string "idp_entity_id"
    t.string "idp_sso_url"
    t.boolean "jit_provisioning", default: false, null: false
    t.datetime "last_login_at"
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_sso_connections_on_organization_id", unique: true
  end

  create_table "sso_domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain", null: false
    t.bigint "sso_connection_id", null: false
    t.datetime "updated_at", null: false
    t.string "verification_token", null: false
    t.datetime "verified_at"
    t.index ["domain"], name: "index_sso_domains_on_verified_domain", unique: true, where: "(verified_at IS NOT NULL)"
    t.index ["sso_connection_id", "domain"], name: "index_sso_domains_on_sso_connection_id_and_domain", unique: true
    t.index ["sso_connection_id"], name: "index_sso_domains_on_sso_connection_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "banned_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.datetime "email_verified_at"
    t.string "locale"
    t.datetime "marketing_consent_at"
    t.jsonb "metadata", default: {}, null: false
    t.string "name"
    t.datetime "onboarding_completed_at"
    t.text "otp_backup_codes"
    t.datetime "otp_enabled_at"
    t.text "otp_secret"
    t.datetime "redacted_at"
    t.datetime "terms_accepted_at"
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["banned_at"], name: "index_users_on_banned_at", where: "(banned_at IS NOT NULL)"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "access_requests", "organizations"
  add_foreign_key "access_requests", "users"
  add_foreign_key "access_requests", "users", column: "completed_by"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agreements_acceptances", "agreements_versions", column: "agreement_version_id"
  add_foreign_key "audit_logs", "organizations", on_delete: :cascade
  add_foreign_key "data_exports", "memberships"
  add_foreign_key "data_exports", "organizations"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "invitations", "users", column: "invited_by_id", on_delete: :nullify
  add_foreign_key "magic_links", "users"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_charges", "pay_subscriptions", column: "subscription_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "projects", "memberships"
  add_foreign_key "projects", "organizations"
  add_foreign_key "refer_visits", "refer_referral_codes", column: "referral_code_id"
  add_foreign_key "saml_auth_requests", "sso_connections", on_delete: :cascade
  add_foreign_key "scim_connections", "organizations", on_delete: :cascade
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "sso_connections", "organizations", on_delete: :cascade
  add_foreign_key "sso_domains", "sso_connections", on_delete: :cascade

  create_function :audit_logs_block_update, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.audit_logs_block_update()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        IF NEW.id              IS DISTINCT FROM OLD.id
        OR NEW.action          IS DISTINCT FROM OLD.action
        OR NEW.actor_kind      IS DISTINCT FROM OLD.actor_kind
        OR NEW.mini_app        IS DISTINCT FROM OLD.mini_app
        OR NEW.organization_id IS DISTINCT FROM OLD.organization_id
        OR NEW.metadata::text  IS DISTINCT FROM OLD.metadata::text
        OR NEW.created_at      IS DISTINCT FROM OLD.created_at
        OR NEW.updated_at      IS DISTINCT FROM OLD.updated_at
        OR (NEW.actor_id     IS NOT NULL AND NEW.actor_id     IS DISTINCT FROM OLD.actor_id)
        OR (NEW.actor_type   IS NOT NULL AND NEW.actor_type   IS DISTINCT FROM OLD.actor_type)
        OR (NEW.subject_id   IS NOT NULL AND NEW.subject_id   IS DISTINCT FROM OLD.subject_id)
        OR (NEW.subject_type IS NOT NULL AND NEW.subject_type IS DISTINCT FROM OLD.subject_type)
        THEN
          RAISE EXCEPTION 'audit_logs is append-only; rows cannot be modified after creation';
        END IF;
        RETURN NEW;
      END;
      $function$
  SQL

  create_function :audit_logs_block_truncate, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.audit_logs_block_truncate()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        RAISE EXCEPTION 'audit_logs is append-only; TRUNCATE is not permitted';
        RETURN NULL;
      END;
      $function$
  SQL

  create_trigger :audit_logs_append_only_update, sql_definition: <<-SQL
      CREATE TRIGGER audit_logs_append_only_update BEFORE UPDATE ON public.audit_logs FOR EACH ROW EXECUTE FUNCTION audit_logs_block_update()
  SQL

  create_trigger :audit_logs_append_only_truncate, sql_definition: <<-SQL
      CREATE TRIGGER audit_logs_append_only_truncate BEFORE TRUNCATE ON public.audit_logs FOR EACH STATEMENT EXECUTE FUNCTION audit_logs_block_truncate()
  SQL
end
