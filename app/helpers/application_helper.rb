# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def flash_style(type)
    case type
    when "notice" then "alert-info"
    when "alert", "error" then "alert-error"
    end
  end

  def flash_role(type)
    case type
    when "alert", "error" then "alert"
    else "status"
    end
  end

  def resolve_icon(icon, classes: "size-6")
    return if icon.blank?

    if icon.html_safe?
      icon
    elsif icon.match?(/svg/)
      inline_svg_tag icon, class: classes, "aria-hidden": "true"
    elsif icon.start_with?("http") || icon.match?(/\.(png|jpg|webp|avif|gif)$/)
      image_tag icon, alt: "", class: "#{classes} rounded"
    else
      tag.span icon, aria: { hidden: true }
    end
  end

  def nav_link(label, path, icon: nil, badge: nil, todo_dot: false, wrapper: :li, wrapper_class: nil, **)
    resolved_icon = resolve_icon(icon)

    badge_span = content_tag(:span, badge, class: "badge badge-xs badge-warning") if badge.present?
    todo_dot_span = content_tag(:span, "", class: "bg-warning rounded-full w-2 h-2 ml-auto", "aria-hidden": "true") if todo_dot

    link_content = active_link_to(path, class_active: "menu-active", class: "flex justify-between items-center whitespace-nowrap justify-start min-w-0", title: label, "aria-current": ("page" if current_page?(path)), **) do
      safe_join([
        resolved_icon,
        content_tag(:span, label, class: "[[data-expanded=false]_&]:hidden truncate min-w-0"),
        badge_span,
        todo_dot_span
      ].compact)
    end

    case wrapper
    when false, nil
      link_content
    else
      tag.send(wrapper, class: wrapper_class) { link_content }
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
      fr: "🇫🇷",
      pl: "🇵🇱"
    }
    locales[locale.to_sym]
  end

  def locale_to_name(locale)
    names = {
      en: "English",
      es: "Español",
      uk: "Українська",
      fr: "Français",
      pl: "Polski"
    }
    names[locale.to_sym]
  end

  def sanitize_url(url)
    uri = URI.parse(url.to_s)
    uri.scheme&.match?(/\Ahttps?\z/) ? url : "#"
  rescue URI::InvalidURIError
    "#"
  end

  def sanitize_embed(html)
    sanitize(html, tags: %w[iframe], attributes: %w[src width height frameborder allowfullscreen allow style title referrerpolicy])
  end

  def back_path_with_fallback(fallback_path = root_path)
    if request.referer.present? && URI(request.referer).host == request.host && request.referer != request.original_url
      :back
    else
      fallback_path
    end
  end

  def admin_links
    all_admin_links.select { |link| Rails.env.development? || !link[:dev_only] }
  end

  def content_card_classes(overflow: nil)
    classes = ["flex-grow flex flex-col min-w-0 bg-base-100 lg:my-2 lg:mr-2"]
    classes << overflow if overflow
    classes << if Current.organization
                 "lg:rounded-r-2xl lg:border-y lg:border-r lg:border-base-content/10"
               else
                 "lg:rounded-lg lg:border lg:border-base-content/10"
               end
    classes.join(" ")
  end

  def breadcrumbs(*items)
    tag.nav aria: { label: "Breadcrumb" } do
      tag.div class: "breadcrumbs text-base font-normal" do
        tag.ul do
          safe_join(items.each_with_index.map do |item, index|
            label, path = item
            is_last = index == items.size - 1

            tag.li(class: ("font-medium" if is_last), **(is_last ? { "aria-current": "page" } : {})) do
              if !is_last && path
                link_to(label, path)
              else
                label
              end
            end
          end)
        end
      end
    end
  end

  def number_to_compact(number)
    return "-" if number.blank?

    number_to_human(number, units: { thousand: "k", million: "M", billion: "B" }, precision: 2, significant: false, format: "%n%u")
  end

  def stat_badge(value, median, precision: nil)
    return content_tag(:span, "-", class: "badge badge-ghost") if value.blank? || value.zero?

    formatted = precision ? number_to_percentage(value, precision: precision) : number_to_compact(value)
    badge_class = if median.zero? then "badge-ghost"
                  elsif value >= median then "badge-success"
                  else "badge-error"
                  end
    content_tag(:span, formatted, class: "badge #{badge_class}")
  end

  private

  def all_admin_links
    [
      {
        name: "Avo admin",
        path: "/admin/avo/resources/users",
        icon: "🥑"
      },
      {
        name: "Feature Flags",
        path: "/feature_flags",
        icon: "🎛️"
      },
      {
        name: "Jobs",
        path: "/jobs",
        icon: "⚙️"
      },
      {
        name: "Active Storage",
        path: "/active_storage_dashboard",
        icon: "💾"
      },
      {
        name: "Healthcheck",
        path: "/healthcheck",
        icon: "🟢"
      },
      {
        name: "Lookbook",
        path: "/lookbook",
        icon: "👀",
        dev_only: true
      },
      {
        name: "Letter Opener",
        path: "/letter_opener",
        icon: "📨",
        dev_only: true
      }
    ]
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

  def viewport_meta_tag
    content = ["width=device-width,initial-scale=1,viewport-fit=cover"]
    content << "interactive-widget=resizes-content" unless browser.safari?
    content << "maximum-scale=1, user-scalable=0" if hotwire_native_app? || browser.device.mobile?
    tag.meta name: "viewport", content: content.join(",")
  end
end
