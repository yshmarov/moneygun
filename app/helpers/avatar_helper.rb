# frozen_string_literal: true

module AvatarHelper
  def avatar_src(thumbnail)
    rails_storage_proxy_path(thumbnail)
  end
end
