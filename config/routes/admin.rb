authenticate :user, ->(user) { user.admin? } do
  mount Profitable::Engine => "/profitable"
  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount Avo::Engine, at: Avo.configuration.root_path
  mount ActiveAnalytics::Engine, at: "analytics"
  mount ActiveStorageDashboard::Engine, at: "/active_storage_dashboard"
end

if Rails.env.development?
  mount Lookbook::Engine, at: "/lookbook"
end
