# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :books, [BookType], null: false, description: "Returns a list of the books the current user has access to."
    def books
      Book.all
    end

    field :book, BookType, null: false do
      argument :id, ID, required: true
    end
    def book(id:)
      Book.find(id)
    end
  end
end
