module ApplicationHelper
  include Pagy::Frontend

  def flash_style(type)
    case type
    when "notice" then "du-alert-info"
    when "alert", "error" then "du-alert-error"
    end
  end

  def nav_link(label, path, icon: nil, badge: nil, **options)
    icon = inline_svg_tag icon, class: "size-6 w-6 h-6" if icon&.match?(/svg/)
    badge_span = content_tag(:span, badge, class: "du-badge du-badge-xs du-badge-warning") if badge && badge.to_i.positive?
    content_tag(:li) do
      active_link_to path, class_active: "du-menu-active", class: "whitespace-nowrap justify-start [[data-expanded=false]_&]:justify-center", title: label, **options do
        safe_join([
          icon,
          content_tag(:span, label, class: "[[data-expanded=false]_&]:hidden"),
          badge_span
        ].compact)
      end
    end
  end

  def modal(**options, &block)
    render "shared/modal", **options, &block
  end

  def avo_masquerade_path(resource, *args)
    scope = Devise::Mapping.find_scope!(resource)

    opts = args.shift || {}
    opts[:masqueraded_resource_class] = resource.class.name

    opts[Devise.masquerade_param] = resource.masquerade_key

    Rails.application.routes.url_helpers.send(:"#{scope}_masquerade_index_path", opts, *args)
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
end
