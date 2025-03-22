class ScaffoldGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  hook_for :scaffold, in: :rails, default: true, type: :boolean

  def add_to_navigation
    append_to_file "app/views/shared/_sidebar_links.html.erb" do
      <<-ERB
<%= active_link_to #{index_helper(type: :path)}, class_active: "bg-gray-200", class: "w-full items-center btn btn-transparent" do %>
  <div>
    <%= inline_svg_tag "svg/question-mark-circle.svg", class: "size-5" %>
  </div>
  <div>
  #{plural_table_name.titleize}
  </div>
<% end %>
      ERB
    end
  end
end
