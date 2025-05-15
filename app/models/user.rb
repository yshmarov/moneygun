class User < ApplicationRecord
  include User::Authentication
  include User::Multitenancy
end
