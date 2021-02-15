# frozen_string_literal: true

# == Schema Information
#
# Table name: books
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  owner_id   :uuid             not null
#
class Book < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :book_rights, dependent: :destroy

  validates :name, presence: true
  validates :owner, presence: true
end
