# frozen_string_literal: true

class Organization < ApplicationRecord
  include Organization::Multitenancy
  include Organization::Transfer
  include Organization::Billing
  include Organization::Logo
  include Organization::Community

  has_many :projects, dependent: :destroy

  validates :name, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
