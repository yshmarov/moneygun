# frozen_string_literal: true

constraints AdminConstraint.new do
  mount_avo
  mount GoodJob::Engine, at: "/jobs"
  mount PgHero::Engine, at: "/pghero"
  mount Flipper::UI.app(Flipper) => "/feature_flags"
  mount Allgood::Engine => "/healthcheck"
end

mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
