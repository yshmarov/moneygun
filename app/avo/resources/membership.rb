class Avo::Resources::Membership < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :organization_id, as: :number
    field :user_id, as: :number
    field :role, as: :select, enum: ::Membership.roles
    field :organization, as: :belongs_to
    field :user, as: :belongs_to
  end
end
