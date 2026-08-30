# frozen_string_literal: true

module NavigationHelper
  def nav_link(label, path, icon: nil, badge: nil, todo_dot: false, chevron: false, external: false, wrapper: :li, wrapper_class: nil, **options)
    resolved_icon = resolve_icon(icon)

    badge_span = content_tag(:span, badge, class: "badge badge-xs badge-warning") if badge.present?
    todo_dot_span = content_tag(:span, "", class: "bg-warning rounded-full size-2 ml-auto", "aria-hidden": "true") if todo_dot
    chevron_span = if external
                     icon_tag("arrow-top-right-on-square", class: "size-5 ml-auto text-base-content/60 shrink-0")
                   elsif chevron
                     icon_tag("chevron-right", class: "size-5 ml-auto text-base-content/60 shrink-0")
                   end
    options = { target: "_blank", rel: "noopener", active: false }.merge(options) if external

    link_content = active_link_to(path, class_active: "menu-active", class: "flex justify-between items-center whitespace-nowrap justify-start min-w-0", title: label, "aria-current": ("page" if current_page?(path)), **options) do
      safe_join([
        resolved_icon,
        content_tag(:span, label, class: "[[data-expanded=false]_&]:hidden truncate min-w-0"),
        badge_span,
        todo_dot_span,
        chevron_span
      ].compact)
    end

    wrapper ? tag.send(wrapper, class: wrapper_class) { link_content } : link_content
  end

  def back_path_with_fallback(fallback_path = root_path)
    return fallback_path if request.referer.blank? || request.referer == request.original_url

    referer_host = URI(request.referer).host
    referer_host == request.host ? :back : fallback_path
  rescue URI::InvalidURIError
    fallback_path
  end
end
