class Avo::Resources::ReferReferral < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Refer::Referral
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id
    field :referrer_type, as: :text
    field :referrer_id, as: :number
    field :referee_type, as: :text
    field :referee_id, as: :number
    field :referral_code_id, as: :number
    field :completed_at, as: :date_time
    field :referrer, as: :belongs_to, polymorphic_as: :referrer, types: [ User ]
    field :referee, as: :belongs_to, polymorphic_as: :referee, types: [] # Types weren't computed correctly. Please configure them.
    field :referral_code, as: :belongs_to
  end
end
