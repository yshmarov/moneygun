# frozen_string_literal: true

module UserHelper
  def user_avatar(user, classes: "w-8 h-8")
    render AvatarComponent.new(
      src: (avatar_src(user.avatar_thumbnail) if user.avatar.attached?),
      alt: user.name.presence || user.email,
      initials: user.name.presence&.first(2) || user.email.first(2),
      classes: classes,
      variant: :user
    )
  end
end
