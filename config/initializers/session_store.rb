# frozen_string_literal: true

# Configure session store for better mobile persistence
# The session cookie will persist even when the browser is closed
Rails.application.config.session_store :cookie_store,
                                       key: "_#{Rails.application.class.module_parent_name.downcase}_session",
                                       expire_after: 2.years,
                                       secure: Rails.env.production?,
                                       httponly: true,
                                       same_site: :lax
