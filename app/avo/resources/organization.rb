class Avo::Resources::Organization < Avo::BaseResource
  self.title = -> {
    [ record.id, record.name ].join("/")
  }
  self.attachments = [ :logo ]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) },
    item: -> {
      {
        title: [ record.id, record.name ].join(" ")
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
      field :memberships, as: :has_many,
            attach_scope: lambda {
              query.where.not(id: parent.memberships.select(:id)).order(created_at: :desc)
            }
      field :users, as: :has_many, through: :memberships,
      attach_scope: lambda {
        query.where.not(id: parent.memberships.select(:user_id)).order(email: :asc)
      }
    end
  end
end
