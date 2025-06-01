# Pay::Charge.ancestors.include?(ChargeExtensions)
# Pay::Charge.new.respond_to?(:complete_referral, true)
module ChargeExtensions
  extend ActiveSupport::Concern

  included do
    after_create_commit :complete_referral
  end

  def complete_referral
    customer.owner.owner.referral&.complete!
  end
end

Rails.configuration.to_prepare do
  Pay::Charge.include ChargeExtensions
end
