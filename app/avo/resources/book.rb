class Avo::Resources::Book < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :payload, as: :code, disabled: true
    field :pdfs, as: :file, attach_many: true
    field :audios, as: :file, attach_many: true
  end
end
