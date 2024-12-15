class Avo::Resources::User < Avo::BaseResource
  self.title = :email
  # self.includes = []
  # self.attachments = []
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], email_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :admin, as: :boolean
    field :invitation_token, as: :text
    field :invitation_created_at, as: :date_time
    field :invitation_sent_at, as: :date_time
    field :invitation_accepted_at, as: :date_time
    field :invitation_limit, as: :number
    # field :invited_by_type, as: :text
    # field :invited_by_id, as: :number
    field :invitations_count, as: :number
    # field :invited_by, as: :belongs_to
    field :memberships, as: :has_many
    field :organizations, as: :has_many, through: :memberships
    field :owned_organizations, as: :has_many
  end
end
