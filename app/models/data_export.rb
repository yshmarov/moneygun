# frozen_string_literal: true

class DataExport < ApplicationRecord
  EXPIRY = 7.days

  belongs_to :organization
  belongs_to :membership

  validates :membership, same_organization: true

  has_one_attached :file
  has_many :audit_logs, as: :subject, dependent: :nullify

  enum :status, %w[pending completed failed].index_by(&:itself), default: "pending"

  scope :recent, -> { order(created_at: :desc) }
  scope :expired, -> { where(created_at: ...EXPIRY.ago) }

  after_create_commit :log_requested

  def expires_at
    created_at + EXPIRY
  end

  def expired?
    expires_at.past?
  end

  def downloadable?
    completed? && file.attached? && !expired?
  end

  def complete!(io)
    transaction do
      file.attach(io: io, filename: filename, content_type: "application/zip")
      completed!
    end
  end

  def filename
    "#{organization.name.parameterize}-data-export-#{created_at.to_date.iso8601}.zip"
  end

  def log_downloaded!(by:)
    AuditLog.log!(organization: organization, mini_app: "organization", subject: self, actor: by, action: "organization.data_export.downloaded", actor_kind: "member")
  end

  def active_storage_accessible_to?(user, **)
    user.present? && organization.memberships.active.where(role: "admin").exists?(user: user)
  end

  private

  def log_requested
    AuditLog.log!(organization: organization, mini_app: "organization", subject: self, actor: membership, action: "organization.data_export.requested", actor_kind: "member")
  end
end
