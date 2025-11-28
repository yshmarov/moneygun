# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :organization
  validates :name, presence: true, uniqueness: { scope: :organization_id }

  has_one_attached :document
  has_many_attached :attachments
end
