authenticate :user, ->(user) { user.admin? } do
  mount Profitable::Engine => "/profitable"
  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount Avo::Engine, at: Avo.configuration.root_path
end
