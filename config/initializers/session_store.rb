# frozen_string_literal: true

# Use Solid Cache for server-side sessions in production.
# Eliminates the 4KB cookie size limit that causes OAuth failures
# during rapid back-to-back flows (e.g., connecting multiple accounts).
if Rails.env.production?
  Rails.application.config.session_store :cache_store,
                                         key: "_#{Rails.application.class.module_parent_name.downcase}_session",
                                         expire_after: 2.years,
                                         secure: true,
                                         httponly: true,
                                         same_site: :lax
else
  Rails.application.config.session_store :cookie_store,
                                         key: "_#{Rails.application.class.module_parent_name.downcase}_session",
                                         expire_after: 2.years,
                                         httponly: true,
                                         same_site: :lax
end
