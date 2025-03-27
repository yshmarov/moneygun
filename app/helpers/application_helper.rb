module ApplicationHelper
  def flash_style(type)
    case type
    when "notice" then "bg-green-100 border-green-400 text-green-700 dark:bg-green-900/50 dark:border-green-500 dark:text-green-200"
    when "alert" then "bg-red-100 border-red-400 text-red-700 dark:bg-red-900/50 dark:border-red-500 dark:text-red-200"
    end
  end

  def nav_link(label, path, icon:, **options)
    icon = inline_svg_tag icon, class: "size-5" if icon.match?(/svg/)
    active_link_to path,
      class_active: "bg-gray-200 dark:bg-gray-700 text-gray-900 dark:text-gray-100",
      class: "w-full items-center btn btn-transparent btn-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100",
      **options do
      content_tag(:div) do
        icon
      end +
      content_tag(:div) do
        label
      end
    end
  end
end
