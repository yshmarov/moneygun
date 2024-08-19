module AccountsHelper
  def account_avatar(account)
    if account.logo.attached?
      image_tag account.logo, class: "rounded-full size-8"
    else
      tag.div account.name[0], class: "size-8 uppercase rounded-full bg-gray-300 text-white flex items-center justify-center"
    end
  end
end
