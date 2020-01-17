# frozen_string_literal: true

# == Schema Information
#
# Table name: books
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  owner_id   :uuid             not null
#

class BookSerializer < ApplicationSerializer
  attribute :id
  attribute :name
  belongs_to :owner

  class UserSerializer < ApplicationSerializer
    attribute :id
    attribute :display_name
  end
end
