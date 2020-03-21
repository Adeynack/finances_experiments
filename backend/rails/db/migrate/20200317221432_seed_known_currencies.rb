# frozen_string_literal: true

class SeedKnownCurrencies < ActiveRecord::Migration[6.0]
  def up
    Currency.seed_known_currencies
  end
end
