module UserHelper
  def user_avatar(user)
    tag.div user.email[0..1], class: "bg-gray-400 rounded-full size-8 justify-center flex items-center border text-xs font-medium"
  end
end
