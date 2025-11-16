# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def flash_style(type)
    case type
    when "notice" then "alert-info"
    when "alert", "error" then "alert-error"
    end
  end

  def nav_link(label, path, icon: nil, badge: nil, todo_dot: false, wrapper: :li, **)
    resolved_icon = if icon&.match?(/svg/)
                      inline_svg_tag icon, class: "size-6 w-6 h-6"
                    elsif icon&.start_with?("http") || icon&.match?(/\.(png|jpg|webp|avif|gif)$/)
                      image_tag icon, class: "size-6 w-6 h-6 rounded"
                    else
                      icon
                    end

    badge_span = content_tag(:span, badge, class: "badge badge-xs badge-warning") if badge.present?
    todo_dot_span = content_tag(:span, "", class: "bg-warning rounded-full w-2 h-2 ml-auto") if todo_dot

    link_content = active_link_to(path, class_active: "menu-active", class: "flex justify-between items-center whitespace-nowrap justify-start", title: label, **) do
      safe_join([
        resolved_icon,
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

  def admin_link_options
    [{
      name: "Admin",
      path: "/admin/avo/resources/users",
      icon: "👮"
    },
     {
       name: "Profitable",
       path: "/profitable",
       icon: "🤑"
     },
     {
       name: "Jobs",
       path: "/jobs",
       icon: "⚙️"
     },
     {
       name: "Analytics",
       path: "/analytics",
       icon: "📊"
     },
     {
       name: "Active Storage",
       path: "/active_storage_dashboard",
       icon: "💾"
     },
     {
       name: "Feature Flags",
       path: "/feature_flags",
       icon: "🎛️"
     },
     {
       name: "Lookbook",
       path: "/lookbook",
       icon: "👀"
     },
     {
       name: "Healthcheck",
       path: "/healthcheck",
       icon: "🟢"
     },
     {
       name: "Letter Opener",
       path: "/letter_opener",
       icon: "📨"
     }]
  end

  def admin_link_names
    ["Admin", "Profitable", "Analytics", "Feature Flags"]
  end

  def admin_links
    admin_link_options.select { |link| admin_link_names.include?(link[:name]) }
  end

  def dev_links
    admin_link_options.reject { |link| admin_link_names.include?(link[:name]) }
  end

  def boolean_to_icon(value)
    if value
      "✅"
    else
      "❌"
    end
  end

  def formatted_title
    app_name = Rails.application.config_for(:settings).dig(:site, :name)
    org_name = defined?(Current.organization) && Current.organization&.name.present? ? Current.organization.name : nil

    title = content_for(:title).presence || "#{controller_name.humanize} #{action_name.humanize}"

    parts = [title, org_name, app_name].compact
    parts.join(" - ")
  end
end
