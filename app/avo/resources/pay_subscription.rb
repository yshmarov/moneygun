# frozen_string_literal: true

class Avo::Resources::PaySubscription < Avo::BaseResource
  self.title = :processor_id
  self.includes = [:customer]
  self.model_class = ::Pay::Subscription

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
      field :name, as: :text, disabled: true
      field :processor_id, as: :text, disabled: true
      field :customer, as: :belongs_to, disabled: true
      field :processor_plan, as: :text, disabled: true
      field :quantity, as: :number, disabled: true
      field :status, as: :text, sortable: true, disabled: true
      field :current_period_start, as: :date_time, disabled: true
      field :current_period_end, as: :date_time, disabled: true

      # field :trial_ends_at, as: :date_time
      # field :ends_at, as: :date_time
      # field :metered, as: :boolean
      # field :pause_behavior, as: :text
      # field :pause_starts_at, as: :date_time
      # field :pause_resumes_at, as: :date_time

      sidebar do
        field :created_at, as: :date_time, disabled: true, sortable: true
        field :updated_at, as: :date_time, disabled: true, sortable: true
      end
    end

    with_options only_on: :show do
      field :metadata, as: :text
      field :data, as: :text
    end

    field :charges, as: :has_many
  end
end
