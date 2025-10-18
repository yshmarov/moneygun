module ApplicationHelper
  include Pagy::Frontend

  def flash_style(type)
    case type
    when 'notice' then 'alert-info'
    when 'alert', 'error' then 'alert-error'
    end
  end

  def nav_link(label, path, icon: nil, badge: nil, todo_dot: false, wrapper: :li, **options)
    icon = inline_svg_tag icon, class: 'size-6 w-6 h-6' if icon&.match?(/svg/)
    badge_span = content_tag(:span, badge, class: 'badge badge-xs badge-warning') if badge && badge.to_i.positive?
    todo_dot_span = content_tag(:span, '', class: 'bg-warning rounded-full w-2 h-2 ml-auto') if todo_dot

    link_content = active_link_to path, class_active: 'menu-active', class: 'flex justify-between items-center whitespace-nowrap justify-start', title: label, **options do
      safe_join([
        icon,
        content_tag(:span, label, class: '[[data-expanded=false]_&]:hidden'),
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

  def modal(**options, &block)
    render 'shared/modal', **options, &block
  end

  def locale_to_flag(locale)
    locales = {
      en: '🇺🇸',
      es: '🇪🇸',
      uk: '🇺🇦',
      fr: '🇫🇷'
    }
    locales[locale.to_sym]
  end

  def back_path_with_fallback(fallback_path = root_path)
    if request.referrer.present? && URI(request.referrer).host == request.host && request.referrer != request.original_url
      :back
    else
      fallback_path
    end
  end

  def admin_link_options
    [{
      name: 'Admin',
      path: '/admin/avo/resources/users',
      icon: '👮'
    },
    {
      name: 'Profitable',
      path: '/profitable',
      icon: '🤑'
    },
    {
      name: 'Jobs',
      path: '/jobs',
      icon: '⚙️'
    },
    {
      name: 'Analytics',
      path: '/analytics',
      icon: '📊'
    },
    {
      name: 'Active Storage',
      path: '/active_storage_dashboard',
      icon: '💾'
    },
    {
      name: 'Feature Flags',
      path: '/feature_flags',
      icon: '🎛️'
    },
    {
      name: 'Lookbook',
      path: '/lookbook',
      icon: '👀'
    },
    {
      name: 'Letter Opener',
      path: '/letter_opener',
      icon: '📨'
    }]
  end

  def boolean_to_icon(value)
    if value
      '✅'
    else
      '❌'
    end
  end

  def formatted_title
    app_name = Rails.application.config_for(:settings).dig(:site, :name)
    org_name = defined?(Current.organization) && Current.organization&.name.present? ? Current.organization.name : nil

    title = content_for(:title).present? ? content_for(:title) : "#{controller_name.humanize} #{action_name.humanize}"

    parts = [title, org_name, app_name].compact
    parts.join(' - ')
  end
end
