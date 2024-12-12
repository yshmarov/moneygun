class Avo::Resources::User < Avo::BaseResource
  self.title = :email
  self.includes = [:organizations, :memberships]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], email_cont: params[:q], m: "or").result(distinct: false) },
    item: -> {
      {
        title: record.email
      }
    }
  }

  def fields
    main_panel do
      field :id, as: :id
      field :email, as: :text, disabled: true, sortable: true

      sidebar do
        field :created_at, as: :date_time, disabled: true
        field :updated_at, as: :date_time, disabled: true
      end
      sidebar do
        field :invitation_token, as: :text
        field :invitation_created_at, as: :date_time
        field :invitation_sent_at, as: :date_time
        field :invitation_accepted_at, as: :date_time
        field :invitation_limit, as: :number
        # field :invited_by_type, as: :text
        # field :invited_by_id, as: :number
        field :invitations_count, as: :number
        # field :invited_by, as: :belongs_to
      end
    end

    tabs do
      field :memberships, as: :has_many
      field :organizations, as: :has_many, through: :memberships
      field :owned_organizations, as: :has_many
    end
  end
end
