module ApplicationHelper
  def active_link_to(text = nil, path = nil, active_classes: "", active_if: nil, **options, &)
    path ||= text

    classes = active_classes.presence || "font-bold underline"
    is_active = active_if.nil? ? current_page?(path) : active_if

    options[:class] = class_names(options[:class], classes) if is_active

    return link_to(path, options, &) if block_given?

    link_to text, path, options
  end

  def flash_style(type)
    case type
    when "notice" then "bg-green-100 border-green-400 text-green-700"
    when "alert" then "bg-red-100 border-red-400 text-red-700"
    end
  end
end
