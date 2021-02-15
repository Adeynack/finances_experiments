# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :display_name, String, null: false
    field :books, [BookType], null: false, description: "Books owned by the user."
  end
end
