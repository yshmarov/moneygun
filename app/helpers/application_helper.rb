module ApplicationHelper
  def flash_style(type)
    case type
    when "notice" then "du-alert-info"
    when "alert" then "du-alert-error"
    end
  end

  def nav_link(label, path, icon: nil, badge: nil, **options)
    icon = inline_svg_tag icon, class: "size-5" if icon&.match?(/svg/)
    badge_span = content_tag(:span, badge, class: "du-badge du-badge-xs du-badge-warning") if badge
    content_tag(:li) do
      active_link_to path, class_active: "du-menu-active", class: "whitespace-nowrap", **options do
        safe_join([ icon, " ", label, badge_span ].compact)
      end
    end
  end

  def modal(**options, &block)
    render "shared/modal", **options, &block
  end
end
