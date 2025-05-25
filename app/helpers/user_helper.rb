module UserHelper
  def user_avatar(user)
    tag.div class: "du-avatar du-avatar-placeholder" do
      tag.div class: "bg-neutral text-neutral-content w-8 rounded-full" do
        tag.span user.email[0..1].upcase, class: "text-xs"
      end
    end
  end
end
