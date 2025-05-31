module UserHelper
  def user_avatar(user)
    if user.connected_accounts.any?
      image_tag user.connected_accounts.first.image_url, alt: user.connected_accounts.first.name, class: "w-8 h-8 rounded-full"
    else
      tag.div class: "du-avatar du-avatar-placeholder" do
        tag.div class: "bg-neutral text-neutral-content w-8 rounded-full" do
          tag.span user.email[0..1].upcase, class: "text-xs"
        end
      end
    end
  end
end
