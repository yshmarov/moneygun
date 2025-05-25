class Avo::Resources::Membership < Avo::BaseResource
  self.title = -> {
    [ record.id, record.user.email, record.organization.name ].join(" / ")
  }
  self.includes = [ :organization, :user ]
  self.visible_on_sidebar = false
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    main_panel do
      field :id, as: :id
      field :role, as: :select, enum: ::Membership.roles, sortable: true
      field :organization, as: :belongs_to, disabled: true
      field :user, as: :belongs_to, disabled: true

      sidebar do
        field :created_at, as: :date_time, disabled: true, format: "DDDD, T"
        field :updated_at, as: :date_time, disabled: true, format: "DDDD, T"
      end
    end
  end
end
