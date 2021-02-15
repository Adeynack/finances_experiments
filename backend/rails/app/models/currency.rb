# frozen_string_literal: true

# == Schema Information
#
# Table name: currencies
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  iso_code   :string
#  name       :string           not null
#  prefix     :string
#  suffix     :string
#
class Currency < ApplicationRecord
  belongs_to :book, optional: true

  has_many :account, dependent: :destroy

  validates :name, presence: true

  class << self
    # Upsert the known currencies into the database.
    # Useful to:
    #   - initially fill the database with currencies from the Gem
    #   - add new currencies if any are added to the Gem
    def seed_known_currencies
      Currency.transaction do
        Money::Currency.all.each do |c| # rubocop:disable Rails/FindEach
          Currency.find_or_create_by(iso_code: c.iso_code).update!(
            name: c.name,
            prefix: c.symbol_first ? c.symbol : nil,
            suffix: c.symbol_first ? nil : c.symbol
          )
        end
      end
    end
  end
end
