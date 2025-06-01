# frozen_string_literal: true

class Avo::Resources::PayCustomer < Avo::BaseResource
  self.title = :processor_id
  self.includes = [ :owner ]
  self.model_class = ::Pay::Customer

  self.search = {
    query: -> { query.ransack(id_eq: params[:q], processor_id_cont: params[:q], m: "or").result(distinct: false) },
    item: lambda {
      {
        title: record.processor_id
      }
    }
  }

  def fields
    main_panel do
      field :id, as: :id
      field :processor_id, as: :text, disabled: true
      field :owner, as: :belongs_to, polymorphic_as: :owner, types: [ ::User ], disabled: true
      # Pay::Subscription
      # field :charges, as: :has_many
      # field :charges, as: :has_many, use_resource: Avo::Resources::PayCharge
      # field :subscriptions, as: :has_many

      sidebar do
        field :created_at, as: :date_time, disabled: true, sortable: true
        field :updated_at, as: :date_time, disabled: true, sortable: true
      end
    end
    with_options only_on: :show do
      field :data, as: :text
    end
  end
end
