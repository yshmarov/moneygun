module ApplicationHelper
  def flash_style(type)
    case type
    when "notice" then "bg-green-100 border-green-400 text-green-700"
    when "alert" then "bg-red-100 border-red-400 text-red-700"
    end
  end

  def nav_link(label, path, icon:, **options)
    icon = inline_svg_tag icon, class: "size-5" if icon.match?(/svg/)
    active_link_to path, class_active: "bg-gray-200", class: "w-full items-center btn btn-transparent btn-sm", **options do
      content_tag(:div, class: "text-lg") do
        icon
      end +
      content_tag(:div) do
        label
      end
    end
  end
end
