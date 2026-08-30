# frozen_string_literal: true

module IconHelper
  def icon_tag(name, **options)
    tag.span \
      class: class_names("icon icon--#{File.basename(name.to_s, '.svg')}", options.delete(:class)),
      aria: { hidden: true }.merge(options.delete(:aria) || {}),
      **options
  end

  def resolve_icon(icon, classes: "size-6")
    return if icon.blank?

    if icon.html_safe?
      icon
    elsif icon.start_with?("svg/")
      icon_tag icon, class: classes
    elsif icon.start_with?("http") || icon.match?(/\.(png|jpg|webp|avif|gif)$/)
      image_tag icon, alt: "", class: class_names(classes, "rounded")
    else
      tag.span icon, aria: { hidden: true }
    end
  end
end
