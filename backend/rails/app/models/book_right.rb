# frozen_string_literal: true

# == Schema Information
#
# Table name: book_rights
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :uuid
#  user_id    :uuid             not null
#  access     :enum             not null
#
class BookRight < ApplicationRecord
  belongs_to :book
  belongs_to :user

  # Abstracted to keep in sync with Types::BookRightAccess (app/graphql/types)
  RIGHT_VALUES = {
    admin: {
      description: "Can access, modify, and administrate the book."
    },
    write: {
      description: "Can access, and modify the book."
    },
    read: {
      description: "Can access the book only to read it."
    }
  }.freeze

  enum right: RIGHT_VALUES.map { |k, _| [k, k.to_s] }.to_h
end
