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

FactoryBot.define do
  factory :session do
  end
end
