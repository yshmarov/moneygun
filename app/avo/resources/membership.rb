class Avo::Resources::Membership < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    main_panel do
      field :id, as: :id
      field :role, as: :select, enum: ::Membership.roles
      field :organization, as: :belongs_to
      field :user, as: :belongs_to

      sidebar do
        field :created_at, as: :date_time, disabled: true
        field :updated_at, as: :date_time, disabled: true
      end
    end
  end
end
