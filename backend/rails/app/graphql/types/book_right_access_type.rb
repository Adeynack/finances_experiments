# frozen_string_literal: true

module Types
  class BookRightAccessType < Types::BaseEnum
    value "ADMIN", "Can access, modify, and administrate the book.", value: "admin"
    value "WRITE", "Can access, and modify the book.", value: "write"
    value "READ", "Can access the book only to read it.", value: "read"

    # TODO: Make this work. Somehow, the model class is not accessible :'(
    # BookRight::RIGHT_VALUES.each do |k, v|
    #   binding.pry
    #   value k.to_s.upcase, v[:description], value: k.to_s
    # end
  end
end
