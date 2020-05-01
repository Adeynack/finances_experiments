# frozen_string_literal: true

module Types
  class BookRightType < Types::BaseObject
    field :book, BookType, null: false
    field :user, UserType, null: false
    field :access, BookRightAccessType, null: false
  end
end
