module AccountsHelper
  def account_avatar(account)
    if account.logo.attached?
      image_tag account.logo, class: "rounded size-8", alt: account.name
    else
      tag.div account.name[0..1], class: "size-8 uppercase rounded bg-gray-600 text-white text-xs flex items-center justify-center"
    end
  end
end
