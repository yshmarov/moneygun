# frozen_string_literal: true

class Avo::Resources::ConnectedAccount < Avo::BaseResource
  self.title = :uid
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id
    field :provider, disabled: true
    field :uid, as: :text, disabled: true
    field :user, as: :belongs_to
    field :payload, as: :code, disabled: true
  end
end
