class User < ApplicationRecord
  include User::Authentication
  include User::Multitenancy

  def self.ransackable_attributes(auth_object = nil)
    %w[id email]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
