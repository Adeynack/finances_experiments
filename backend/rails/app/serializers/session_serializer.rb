# frozen_string_literal: true

# == Schema Information
#
# Table name: sessions
#
#  id             :uuid             not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#  expired_at     :datetime
#  last_active_at :datetime
#  user_agent     :string
#  ip             :string
#

class SessionSerializer < ApplicationSerializer
  attribute :id, key: :token
  attribute :user_id
  attribute :valid_until
end
