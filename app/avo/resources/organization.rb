class Avo::Resources::Organization < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    main_panel do
      field :id, as: :id
      field :name, as: :text, sortable: true
      field :logo, as: :file, is_image: true

      sidebar do
        field :created_at, as: :date_time, disabled: true
        field :updated_at, as: :date_time, disabled: true
      end
    end

    tabs do
      field :memberships, as: :has_many
      field :users, as: :has_many, through: :memberships
      field :owner, as: :belongs_to
    end
  end
end
