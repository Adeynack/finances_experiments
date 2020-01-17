# frozen_string_literal: true

class AccountType
  ACCOUNT_TYPES = [:other, :bank, :card, :investment, :asset, :liability, :loan].freeze
  CATEGORY_TYPES = [:expense, :income].freeze

  TYPES = (ACCOUNT_TYPES + CATEGORY_TYPES).freeze

  def initialize(status)
    @status = status
  end
end
