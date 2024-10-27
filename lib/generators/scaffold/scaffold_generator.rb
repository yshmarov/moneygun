class ScaffoldGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  hook_for :scaffold, in: :rails, default: true, type: :boolean

  def add_to_navigation
    append_to_file "app/views/shared/_nav_links.html.erb" do
      <<-ERB
<%= active_link_to #{index_helper(type: :path)}, class_active: "bg-gray-300", class: "w-full btn btn-transparent" do %>
  <%= inline_svg_tag "svg/question-mark-circle.svg", class: "size-5" %>
  <span>
  #{plural_table_name.titleize}
  </span>
<% end %>
      ERB
    end
  end
end
