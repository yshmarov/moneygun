return if Rails.env.production?

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.find_or_initialize_by(email: 'hello@superails.com')
user.password = 'hello@superails.com'
user.admin = true
user.skip_confirmation_notification!
user.confirmed_at = Time.current
user.save!

organization = Organization.find_or_create_by!(name: 'SupeRails') do |org|
  org.owner = user
end
organization.logo.attach(io: Rails.root.join('test/fixtures/files/superails-logo.png').open, filename: 'superails.png') unless organization.logo.attached?
organization.update!(privacy_setting: :public)

organization = Organization.find_or_create_by!(name: 'Avo') do |org|
  org.owner = user
end
organization.logo.attach(io: Rails.root.join('test/fixtures/files/avo-logo.png').open, filename: 'avo.png') unless organization.logo.attached?
organization.update!(privacy_setting: :restricted)

organization = Organization.find_or_create_by!(name: 'Buzzsprout') do |org|
  org.owner = user
  org.privacy_setting = :private
end
organization.logo.attach(io: Rails.root.join('test/fixtures/files/buzzsprout-logo.png').open, filename: 'buzzsprout.png') unless organization.logo.attached?

# if Rails.application.credentials.dig(:stripe, :private_key).present?
#   product = Stripe::Product.create(name: "Pro plan")
#   Stripe::Price.create(
#     product: product.id,
#     unit_amount: 9900,
#     currency: "usd",
#     recurring: { interval: "month" },
#   )
#   Stripe::Price.create(
#     product: product.id,
#     unit_amount: 99000,
#     currency: "usd",
#     recurring: { interval: "year" },
#   )
# end
