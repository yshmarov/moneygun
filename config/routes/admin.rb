# frozen_string_literal: true

authenticate :user, ->(user) { user.admin? } do
  mount_avo
  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount ActiveStorageDashboard::Engine, at: "/active_storage_dashboard"
  mount Flipper::UI.app(Flipper) => "/feature_flags"
  mount Allgood::Engine => "/healthcheck"
end

if Rails.env.development?
  mount Lookbook::Engine, at: "/lookbook"
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
