class Avo::Resources::ConnectedAccount < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }
  
  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :provider, as: :text
    field :uid, as: :text
    field :access_token, as: :text
    field :refresh_token, as: :text
    field :expires_at, as: :date_time
  end
end
