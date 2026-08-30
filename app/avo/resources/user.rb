# frozen_string_literal: true

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

  def actions
    action Avo::Actions::CompleteUserOnboarding
    action Avo::Actions::BanUser
    action Avo::Actions::UnbanUser
  end

  def fields
    panel do
      field :id, as: :id
      field :email, as: :text, disabled: true, sortable: true
      field :admin, as: :boolean, sortable: true
      field :email_verified_at, as: :date_time, disabled: true, format: "DDDD, T"
      field :onboarding_completed_at, as: :date_time, disabled: true, format: "DDDD, T"
      field :banned_at, as: :date_time, disabled: true, sortable: true, format: "DDDD, T"
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

    field :referrals, as: :has_many
  end
end
