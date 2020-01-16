# == Schema Information
#
# Table name: currencies
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  code       :string
#  book_id    :uuid
#  name       :string           not null
#  prefix     :string
#  suffix     :string
#

class Currency < ApplicationRecord
  belongs_to :book, optional: true

  has_many :account, dependent: :destroy

  validates :name, presence: true
end
