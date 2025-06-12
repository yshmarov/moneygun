module OrganizationsHelper
  def organization_avatar(organization, classes: "size-8")
    if organization.logo.attached?
      image_tag organization.logo, class: "rounded #{classes} object-contain", alt: organization.name
    else
      tag.div organization.name[0..1], class: "uppercase rounded bg-primary/20 text-xs flex items-center justify-center #{classes}"
    end
  end
end
