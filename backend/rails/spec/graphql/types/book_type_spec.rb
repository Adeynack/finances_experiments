# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::BookType do
  fixtures :books
  fixtures :users

  describe "get all books" do
    let :query do
      <<~GRAPHQL
        {
          books {
            name
          }
        }
      GRAPHQL
    end

    subject(:books) do
      FinancesRailsSchema.execute(query).as_json
    end

    fit "returns all books" do
      ap books
    end
  end
end
