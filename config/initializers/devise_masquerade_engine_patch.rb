# config/initializers/devise_masquerade_engine_patch.rb

# Patch for DeviseMasquerade::Controllers::UrlHelpers
#
# Problem:
# - Devise Masquerade defines `_masquerade_index_path` helpers dynamically based on scope.
# - These helpers are only registered in the main application's routes.
# - When called from within an engine (e.g. Avo), these helpers may not be found, raising errors.
#
# Solution:
# - This patch intercepts missing `_masquerade_index_path` method calls.
# - If missing, it forwards them to the main application's route helpers.
# - This ensures compatibility with engines that rely on these routes indirectly.

module DeviseMasquerade
  module Controllers
    module UrlHelpers
      def method_missing(method_name, *args, &block)
        if method_name.to_s.end_with?('_masquerade_index_path')
          ::Rails.application.routes.url_helpers.send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        if method_name.to_s.end_with?('_masquerade_index_path')
          ::Rails.application.routes.url_helpers.respond_to?(method_name)
        else
          super
        end
      end
    end
  end
end
