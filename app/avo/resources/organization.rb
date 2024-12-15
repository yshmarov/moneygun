class Avo::Resources::Organization < Avo::BaseResource
  self.title = -> {
    [ record.id, record.name ].compact.join(" - ")
  }
  # self.includes = []
  # self.attachments = []
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :owner_id, as: :number
    field :logo, as: :file
    field :memberships, as: :has_many
    field :users, as: :has_many, through: :memberships
    field :owner, as: :belongs_to
  end
end
