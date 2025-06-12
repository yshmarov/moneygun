module UserHelper
  def user_avatar(user)
    if user.connected_accounts.any? && user.connected_accounts.first.image_url.present?
      image_tag user.connected_accounts.first.image_url, alt: user.connected_accounts.first.name, class: "w-8 h-8 rounded-full"
    else
      tag.div class: "aspect-square flex items-center justify-center bg-neutral text-neutral-content w-8 rounded-full" do
        tag.span user.email[0..1].upcase, class: "text-xs"
      end
    end
  end
end
