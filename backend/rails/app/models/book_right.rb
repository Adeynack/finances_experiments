# frozen_string_literal: true

# == Schema Information
#
# Table name: book_rights
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint
#  user_id    :bigint           not null
#  right      :enum             not null
#
class BookRight < ApplicationRecord
  belongs_to :book
  belongs_to :user

  enum right: {
    admin: "admin",
    write: "write",
    read: "read"
  }
end
