# frozen_string_literal: true

class AuditLog < ApplicationRecord
  VALUE_FORMAT = /\A[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)*\z/
  ACTOR_KINDS = %w[member user system sso scim api admin].freeze

  belongs_to :organization, optional: true
  belongs_to :subject, polymorphic: true, optional: true
  belongs_to :actor, polymorphic: true, optional: true

  validates :action, :mini_app, :actor_kind, presence: true
  validates :action, :mini_app, format: { with: VALUE_FORMAT }
  validates :actor_kind, inclusion: { in: ACTOR_KINDS }

  before_update { raise ActiveRecord::ReadOnlyRecord, "audit logs are append-only" }
  before_destroy { raise ActiveRecord::ReadOnlyRecord, "audit logs are append-only" }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_mini_app, ->(name) { where(mini_app: ["organization", name.to_s]) }

  def self.preload_actor_users(records)
    memberships = records.filter_map { |record| record.actor if record.actor_type == "Membership" }
    ActiveRecord::Associations::Preloader.new(records: memberships, associations: :user).call
    records
  end

  def self.log!(organization:, action:, actor_kind:, mini_app: "organization", subject: nil, actor: nil, metadata: {})
    create!(
      organization: organization,
      mini_app: mini_app,
      subject: subject,
      actor: actor,
      action: action,
      actor_kind: actor_kind,
      metadata: metadata.merge(snapshot_actor(actor)).merge(snapshot_request)
    )
  end

  def self.log_for_memberships!(memberships, action:, actor_kind: "member", metadata: {})
    memberships.includes(:organization).find_each do |membership|
      log!(organization: membership.organization, actor: membership, action: action, actor_kind: actor_kind, metadata: metadata)
    end
  end

  def self.snapshot_request
    context = Current.request_context
    return {} if context.blank?

    { request: context.slice(:request_id, :ip_address, :user_agent).compact }
  end

  def self.snapshot_actor(actor)
    user = actor.is_a?(Membership) ? actor.user : actor if actor.is_a?(Membership) || actor.is_a?(User)
    return {} unless user

    name = actor.is_a?(Membership) ? actor.display_name : user.name
    { actor_user_id: user.id, actor_email: user.email, actor_name: name }.compact
  end

  def actor_label
    metadata["actor_name"].presence || metadata["actor_email"].presence || actor_kind.humanize
  end

  def actor_user
    case actor
    when Membership then actor.user
    when User then actor
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[action actor_kind created_at id mini_app organization_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[actor organization subject]
  end
end
