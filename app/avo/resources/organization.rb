class Avo::Resources::Organization < Avo::BaseResource
  self.title = -> {
    [record.id, record.name].join("/")
  }
  # self.includes = []
  # self.attachments = []
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) },
    item: -> {
      {
        title: [record.id, record.name].join(" ")
      }
    }
  }

  def fields
    main_panel do
      field :id, as: :id
      field :logo, as: :file, is_image: true
      field :name, as: :text, sortable: true
      field :owner, as: :belongs_to

      sidebar do
        field :created_at, as: :date_time, disabled: true, format: "DDDD, T"
        field :updated_at, as: :date_time, disabled: true, format: "DDDD, T"
      end
    end

    tabs do
      field :memberships, as: :has_many
      field :users, as: :has_many, through: :memberships
    end
  end
end
