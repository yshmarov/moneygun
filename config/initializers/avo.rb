# For more information regarding these settings check out our docs https://docs.avohq.io
# The values disaplayed here are the default ones. Uncomment and change them to fit your needs.
Avo.configure do |config|
  ## == Routing ==
  config.root_path = "/admin/avo"
  config.home_path = "/admin/avo/resources/users"

  ## == Licensing ==
  # config.license_key = ENV['AVO_LICENSE_KEY']

  ## == Set the context ==
  config.set_context do
    # Return a context object that gets evaluated within Avo::ApplicationController
  end

  ## == Authentication ==
  config.current_user_method = :current_user
  config.sign_out_path_name = :destroy_user_session_path
  # config.authenticate_with do
  # end

  config.authorization_client = nil
  config.explicit_authorization = true

  ## == Localization ==
  # config.locale = 'en-US'

  ## == Resource options ==
  # config.model_resource_mapping = {}
  # config.default_view_type = :table
  # config.per_page = 24
  # config.per_page_steps = [12, 24, 48, 72]
  # config.via_per_page = 8
  # config.id_links_to_resource = false
  # config.pagination = -> do
  #   {
  #     type: :default,
  #     size: 9, # `[1, 2, 2, 1]` for pagy < 9.0
  #   }
  # end

  ## == Response messages dismiss time ==
  # config.alert_dismiss_time = 5000


  ## == Number of search results to display ==
  # config.search_results_count = 8

  ## == Associations lookup list limit ==
  # config.associations_lookup_list_limit = 1000

  ## == Cache options ==
  ## Provide a lambda to customize the cache store used by Avo.
  ## We compute the cache store by default, this is NOT the default, just an example.
  # config.cache_store = -> {
  #   ActiveSupport::Cache.lookup_store(:solid_cache_store)
  # }
  # config.cache_resources_on_index_view = true
  ## permanent enable or disable cache_resource_filters, default value is false
  # config.cache_resource_filters = false
  ## provide a lambda to enable or disable cache_resource_filters per user/resource.
  # config.cache_resource_filters = -> { current_user.cache_resource_filters? }

  ## == Customization ==
  config.click_row_to_view_record = true
  # config.app_name = 'Avocadelicious'
  # config.timezone = 'UTC'
  # config.currency = 'USD'
  # config.hide_layout_when_printing = false
  # config.full_width_container = false
  # config.full_width_index_view = false
  # config.search_debounce = 300
  # config.view_component_path = "app/components"
  # config.display_license_request_timeout_error = true
  # config.disabled_features = []
  # config.buttons_on_form_footers = true
  # config.field_wrapper_layout = true
  # config.resource_parent_controller = "Avo::ResourcesController"
  # config.first_sorting_option = :desc # :desc or :asc
  # config.exclude_from_status = []

  ## == Breadcrumbs ==
  # config.display_breadcrumbs = true
  # config.set_initial_breadcrumbs do
  #   add_breadcrumb "Home", '/avo'
  # end

  # config.profile_menu = -> {
  #   link "Profile", path: "/avo/profile", icon: "heroicons/outline/user-circle"
  # }
  config.click_row_to_view_record = true

  config.branding = {
    logo: ActionController::Base.helpers.asset_path("logo-long.png"),
    logomark: ActionController::Base.helpers.asset_path("logo.png")
  }
end

if defined?(Avo::MediaLibrary)
  Avo::MediaLibrary.configure do |config|
    config.enabled = true
    config.visible = true
  end
end

unless defined?(Avo::Pro)
  Rails.autoloaders.main.ignore(Rails.root.join("app/avo/cards"))
  Rails.autoloaders.main.ignore(Rails.root.join("app/avo/dashboards"))
end
