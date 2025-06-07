module OrganizationsHelper
  def organization_avatar(organization, classes: "size-8")
    tag.div organization.name[0..1], class: "aspect-square uppercase rounded bg-gray-400 text-xs flex items-center justify-center #{classes}" do
      if organization.logo.attached?
        image_tag organization.logo.variant(:thumb), class: "rounded #{classes} aspect-square object-contain", alt: organization.name
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
        # icon_path: "svg/lock.svg"
        icon_path: "🔒"
      }
    when "restricted"
      {
        display_text: I18n.t("activerecord.attributes.organization.privacy_settings.restricted.display_text"),
        description_text: I18n.t("activerecord.attributes.organization.privacy_settings.restricted.description_text"),
        # icon_path: "svg/envelope.svg"
        icon_path: "📩"
      }
    when "public"
      {
        display_text: I18n.t("activerecord.attributes.organization.privacy_settings.public.display_text"),
        description_text: I18n.t("activerecord.attributes.organization.privacy_settings.public.description_text"),
        # icon_path: "svg/globe.svg"
        icon_path: "🌍"
      }
    end
  end

  def privacy_setting_icon(key)
    tag.span privacy_setting_options(key)[:icon_path], class: "text-lg", alt: key, title: key
  end
end
