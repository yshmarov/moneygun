class ScaffoldGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  hook_for :scaffold, in: :rails, default: true, type: :boolean

  def add_to_navigation
    inject_into_file "app/views/shared/_sidebar.html.erb", before: "<%# add new resources here %>" do
      <<-ERB
      <%= active_link_to account_#{index_helper(type: :path)}(@account), class_active: "bg-gray-300", class: "w-full btn btn-transparent" do %>
        <%= inline_svg_tag "svg/question-mark-circle.svg", class: "size-5" %>
        <span>
        <%= plural_table_name.titleize %>
        </span>
      <% end %>
      ERB
    end
  end

  def add_to_sidebar_2_cols
    inject_into_file "app/views/shared/_sidebar_2_cols.html.erb", before: "<%# add new resources here %>" do
      <<-ERB
      <%= active_link_to account_#{index_helper(type: :path)}(@account), class_active: "bg-gray-300", class: "btn btn-transparent" do %>
        <%= inline_svg_tag "svg/question-mark-circle.svg", class: "size-5" %>
        <span>
        <%= plural_table_name.titleize %>
        </span>
      <% end %>
      ERB
    end
  end
end
