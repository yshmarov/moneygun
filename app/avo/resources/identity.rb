# frozen_string_literal: true

class Avo::Resources::Identity < Avo::BaseResource
  self.title = :uid
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id
    field :provider, disabled: true
    field :uid, as: :text, disabled: true
    field :user, as: :belongs_to
    field :payload, as: :code, disabled: true
  end
end
