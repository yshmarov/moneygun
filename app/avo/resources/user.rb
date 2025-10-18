class Avo::Resources::User < Avo::BaseResource
  self.title = :email
  self.includes = %i[organizations memberships]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], email_cont: params[:q], m: "or").result(distinct: false) },
    item: lambda {
      {
        title: [record.id, record.email].join("/")
      }
    }
  }

  def fields
    main_panel do
      field :id, as: :id
      field :email, as: :text, disabled: true, sortable: true
      field :admin, as: :boolean, sortable: true
      field :login_as, as: :text, as_html: true do
        link_to "Login as", masquerade_path(record) unless record.id == current_user.id
      end

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
      field :organizations, as: :has_many, through: :memberships,
                            attach_scope: lambda {
                              query.where.not(id: parent.memberships.select(:organization_id)).order(name: :asc)
                            }
      field :owned_organizations, as: :has_many
    end

    field :connected_accounts, as: :has_many
    field :referrals, as: :has_many
  end
end
