# frozen_string_literal: true

module OrganizationsHelper
  def organization_avatar(organization, classes: "size-8")
    if organization.logo.attached?
      image_tag organization.logo_thumbnail, class: "rounded #{classes} aspect-square object-contain bg-base-300", alt: organization.name
    else
      tag.div organization.name[0..1], class: "aspect-square uppercase rounded bg-gray-400 text-xs flex items-center justify-center #{classes}"
    end
  end

  def privacy_setting_options(key)
    case key
    when "private"
      {
        display_text: I18n.t("activerecord.attributes.organization.privacy_settings.private.display_text"),
        description_text: I18n.t("activerecord.attributes.organization.privacy_settings.private.description_text"),
        icon: "🔒"
      }
    when "restricted"
      {
        display_text: I18n.t("activerecord.attributes.organization.privacy_settings.restricted.display_text"),
        description_text: I18n.t("activerecord.attributes.organization.privacy_settings.restricted.description_text"),
        icon: "📩"
      }
    when "public"
      {
        display_text: I18n.t("activerecord.attributes.organization.privacy_settings.public.display_text"),
        description_text: I18n.t("activerecord.attributes.organization.privacy_settings.public.description_text"),
        icon: "🌍"
      }
    end
  end

  def privacy_setting_icon(key)
    tag.span privacy_setting_options(key)[:icon], class: "text-lg", alt: key, title: privacy_setting_options(key)[:display_text]
  end

  def render_sidebar_tab(tab, active_tab)
    badge = tab[:badge_count]&.positive? ? tab[:badge_count] : nil
    is_active = active_tab == tab[:key]
    nav_link tab[:label], tab[:path], icon: tab[:icon], badge: badge, active: is_active
  end

  def organization_tabs
    pending_requests_count = Current.organization.received_join_requests.pending.count

    [
      { key: :organization, label: t("organizations.show.title"), path: organization_path(Current.organization), icon: "svg/home.svg" },
      { key: :dashboard, label: t("organizations.dashboard.index.title"), path: organization_dashboard_path(Current.organization), icon: "svg/chart-bar.svg" },
      { key: :paywalled_page, label: t("organizations.dashboard.paywalled_page.title"), path: organization_paywalled_page_path(Current.organization), icon: "svg/lock-closed.svg", condition: Rails.application.credentials.dig(:stripe, :private_key).present? },
      { key: :projects, label: I18n.t("organizations.projects.index.title"), path: organization_projects_path(Current.organization), icon: "svg/question-mark-circle.svg", condition: policy(Project).index? },
      { key: :members, label: t("organizations.memberships.index.title"), path: organization_memberships_path(Current.organization), icon: "svg/user-group.svg", badge_count: pending_requests_count },
      { key: :settings, label: t("organizations.edit.title"), path: edit_organization_path(Current.organization), icon: "svg/cog-6-tooth.svg", condition: Current.membership&.admin? },
      { key: :billing, label: t("organizations.subscriptions.index.title"), path: organization_subscriptions_path(Current.organization), icon: subscription_status_label(Current.organization), condition: Current.membership&.admin? && Rails.application.credentials.dig(:stripe, :private_key).present? }
    ]
  end

  def organization_active_tab
    return :organization if is_active_link?(organization_path(Current.organization), :exact)
    return :dashboard if is_active_link?(organization_dashboard_path(Current.organization), :exact)
    return :paywalled_page if is_active_link?(organization_paywalled_page_path(Current.organization), :exact)
    return :projects if is_active_link?(organization_projects_path(Current.organization), :inclusive)
    return :members if is_active_link?(organization_memberships_path(Current.organization), :inclusive) ||
                       is_active_link?(organization_sent_invitations_path(Current.organization), :inclusive) ||
                       is_active_link?(organization_received_join_requests_path(Current.organization), :inclusive)
    return :settings if is_active_link?(edit_organization_path(Current.organization), :inclusive)
    return :billing if is_active_link?(organization_subscriptions_path(Current.organization), :inclusive)

    nil
  end
end
