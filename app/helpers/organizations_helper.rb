# frozen_string_literal: true

module OrganizationsHelper
  def organization_avatar(organization, classes: "size-8")
    tag.div organization.name[0..1], class: "aspect-square uppercase rounded bg-gray-400 text-xs flex items-center justify-center #{classes}" do
      if organization.logo.attached?
        image_tag organization.logo_thumbnail, class: "rounded #{classes} aspect-square object-cover", alt: organization.name
      else
        tag.div organization.name[0..1], class: "aspect-square uppercase rounded bg-gray-400 text-xs flex items-center justify-center #{classes}"
      end
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

  def organization_tabs
    [
      { key: :organization, label: t("organizations.show.title"), path: organization_path(Current.organization), icon: "svg/home.svg", data: { turbo_action: replace_if_native } },
      { key: :dashboard, label: t("organizations.dashboard.index.title"), path: organization_dashboard_path(Current.organization), icon: "svg/chart-bar.svg", data: { turbo_action: replace_if_native } },
      { key: :paywalled_page, label: t("organizations.dashboard.paywalled_page.title"), path: organization_paywalled_page_path(Current.organization), icon: "🔐", data: { turbo_action: replace_if_native } },
      { key: :projects, label: "Projects", path: organization_projects_path(Current.organization), icon: "svg/question-mark-circle.svg", data: { turbo_action: replace_if_native } }
    ]
  end

  def organization_active_tab
    if is_active_link?(organization_path(Current.organization), :exact)
      :organization
    elsif is_active_link?(organization_dashboard_path(Current.organization), :exact)
      :dashboard
    elsif is_active_link?(organization_paywalled_page_path(Current.organization), :exact)
      :paywalled_page
    elsif is_active_link?(organization_projects_path(Current.organization), :inclusive)
      :projects
    end
  end
end
