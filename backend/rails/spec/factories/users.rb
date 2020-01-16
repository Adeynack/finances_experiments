# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  email           :string           not null
#  display_name    :string           not null
#  password_digest :string
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    display_name { Faker::Name.last_name }
    password { SecureRandom.hex(12) }
  end
end
