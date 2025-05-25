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
        display_text: "Invite only",
        description_text: "People can join your server directly with an invite",
        # icon_path: "svg/lock.svg"
        icon_path: "🔐"
      }
    when "restricted"
      {
        display_text: "Apply to join",
        description_text: "People must submit an application to be approved to join",
        # icon_path: "svg/envelope.svg"
        icon_path: "📨"
      }
    when "public"
      {
        display_text: "Discoverable",
        description_text: "Anyone can join your server directly through Server Discovery",
        # icon_path: "svg/globe.svg"
        icon_path: "🌐"
      }
    end
  end
end
