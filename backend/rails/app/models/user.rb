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

class User < ApplicationRecord
  has_secure_password validations: false

  has_many :books, dependent: :destroy, foreign_key: "owner_id", inverse_of: "owner"

  validates :email, presence: true
  validates :display_name, presence: true
end
