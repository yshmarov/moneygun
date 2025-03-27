class ScaffoldGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  hook_for :scaffold, in: :rails, default: true, type: :boolean

  def add_to_navigation
    append_to_file "app/views/shared/_sidebar_links.html.erb" do
      <<-ERB
<%= nav_link("#{plural_table_name.titleize}", #{index_helper(type: :path)}, icon: "svg/question-mark-circle.svg") %>
      ERB
    end
  end
end
