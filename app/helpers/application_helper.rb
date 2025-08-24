module ApplicationHelper
  include Pagy::Frontend

  def flash_style(type)
    case type
    when "notice" then "du-alert-info"
    when "alert", "error" then "du-alert-error"
    end
  end

  def nav_link(label, path, icon: nil, badge: nil, todo_dot: false, wrapper: :li, **)
    icon = inline_svg_tag icon, class: "size-6 w-6 h-6" if icon&.match?(/svg/)
    badge_span = content_tag(:span, badge, class: "du-badge du-badge-xs du-badge-warning") if badge&.to_i&.positive?
    todo_dot_span = content_tag(:span, "", class: "bg-warning rounded-full w-2 h-2 ml-auto") if todo_dot

    link_content = active_link_to(path, class_active: "du-menu-active", class: "flex justify-between items-center whitespace-nowrap justify-start",
                                        title: label, **) do
      safe_join([
        icon,
        content_tag(:span, label, class: "[[data-expanded=false]_&]:hidden"),
        badge_span,
        todo_dot_span
      ].compact)
    end

    case wrapper
    when false, nil
      link_content
    else
      tag.send(wrapper) { link_content }
    end
  end

  def modal(**, &)
    render("shared/modal", **, &)
  end

  def locale_to_flag(locale)
    locales = {
      en: "🇺🇸",
      es: "🇪🇸",
      uk: "🇺🇦",
      fr: "🇫🇷"
    }
    locales[locale.to_sym]
  end

  def back_path_with_fallback(fallback_path = root_path)
    if request.referer.present? && URI(request.referer).host == request.host && request.referer != request.original_url
      :back
    else
      fallback_path
    end
  end
end
