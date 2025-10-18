# frozen_string_literal: true

class Avo::Resources::PayCharge < Avo::BaseResource
  self.title = :processor_id
  self.includes = %i[customer subscription]
  self.model_class = ::Pay::Charge

  self.search = {
    query: -> { query.ransack(id_eq: params[:q], processor_id_cont: params[:q], m: 'or').result(distinct: false) },
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
      field :customer, as: :belongs_to, disabled: true
      field :subscription, as: :belongs_to, disabled: true
      # number to currency field
      field :amount, as: :text, sortable: true do
        number_to_currency(record.amount / 100.0, unit: helpers.currency_symbol(record.currency)) if record&.amount
      end
      field :amount_refunded, as: :text, sortable: true do
        number_to_currency(record.amount_refunded / 100.0, unit: helpers.currency_symbol(record.currency)) if record&.amount_refunded
      end
      sidebar do
        field :created_at, as: :date_time, disabled: true, sortable: true
        field :updated_at, as: :date_time, disabled: true, sortable: true
      end
    end

    with_options only_on: :show do
      field :metadata, as: :text
      field :data, as: :text
    end
  end
end
