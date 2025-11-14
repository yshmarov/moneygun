# frozen_string_literal: true

module UserHelper
  def user_avatar(user, classes: "w-8 h-8")
    if user.connected_accounts.any? && user.connected_accounts.first.image_url.present?
      image_tag user.connected_accounts.first.image_url, alt: user.connected_accounts.first.name, class: [classes, "rounded-full"].compact
    else
      tag.div class: ["aspect-square flex items-center justify-center bg-neutral text-neutral-content rounded-full", classes].compact do
        tag.span user.email[0..1].upcase, class: "text-xs"
      end
    end
  end
end
