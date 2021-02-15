# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  book_id         :uuid             not null
#  parent_id       :uuid
#  name            :string           not null
#  type            :enum             not null
#  info            :jsonb
#  notes           :string
#  currency_id     :uuid             not null
#  initial_balance :integer
#  active          :boolean          default("true")
#
class Account < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :book
  belongs_to :parent, class_name: "Account", optional: true
  belongs_to :currency

  has_many :child, dependent: :destroy, foreign_key: "parent_id", inverse_of: "parent"

  validates :name, presence: true
  validates :type, presence: true

  before :save do
    self.initial_balance = null if initial_balance == 0
  end
end
