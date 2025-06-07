# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.create!(email: "hello@superails.com", password: "hello@superails.com")
organization = Organization.create!(name: "SupeRails", owner: user)
organization.memberships.create!(user:, role: Membership.roles[:admin])
organization.logo.attach(io: File.open(Rails.root.join("test/fixtures/files/superails-logo.png")), filename: "superails.png")

organization = Organization.create!(name: "Avo", owner: user)
organization.memberships.create!(user:, role: Membership.roles[:admin])
organization.logo.attach(io: File.open(Rails.root.join("test/fixtures/files/avo-logo.png")), filename: "avo.png")

organization = Organization.create!(name: "Buzzsprout", owner: user)
organization.memberships.create!(user:, role: Membership.roles[:admin])
organization.logo.attach(io: File.open(Rails.root.join("test/fixtures/files/buzzsprout-logo.png")), filename: "buzzsprout.png")

# if Rails.application.credentials.dig(:stripe, :secret_key).present?
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
