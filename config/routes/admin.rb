authenticate :user, ->(user) { user.admin? } do
  mount Profitable::Engine => "/profitable"
  mount MissionControl::Jobs::Engine, at: "/jobs"
end
