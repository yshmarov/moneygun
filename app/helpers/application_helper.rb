module ApplicationHelper
  def flash_style(type)
    case type.to_s
    when "notice" then "du-alert-success"
    when "alert" then "du-alert-error"
    end
  end

  def nav_link(label, path, icon:, **options)
    icon = inline_svg_tag icon, class: "size-5" if icon.match?(/svg/)
    active_link_to path, class_active: "bg-gray-200", class: "whitespace-nowrap w-full justify-start du-btn du-btn-ghost du-btn-sm", **options do
      content_tag(:div, class: "text-lg") do
        icon
      end +
        content_tag(:div) do
          label
        end
    end
  end
end
