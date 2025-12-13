# frozen_string_literal: true

namespace :hotwire_native do
  namespace :v1 do
    namespace :android do
      resource :path_configuration, only: :show
    end
    namespace :ios do
      resource :path_configuration, only: :show
    end
  end

  # get "tab0", to: "tabs#tab0"
  get "tab1", to: "tabs#tab1"
  get "tab2", to: "tabs#tab2"
end
