# frozen_string_literal: true

# == Schema Information
#
# Table name: sessions
#
#  id             :uuid             not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#  last_active_at :datetime
#  user_agent     :string
#  ip             :string
#

class Session < ApplicationRecord
  belongs_to :user

  EXPIRES_AFTER = 20.minutes

  scope :expired, -> do
    where("sessions.last_active_at < ?", EXPIRES_AFTER.ago)
  end

  before_save do
    self.last_active_at ||= DateTime.current
    self.user_agent = user_agent&.truncate(255)
  end

  def valid_until
    last_active_at + EXPIRES_AFTER
  end

  class << self
    def authenticate_and_create(params)
      user = User.find_by(email: params[:email])
      raise API::V1::Errors::Unauthorized, "Invalid credentials" unless user&.authenticate(params[:password])

      session = Session.find_or_initialize_by(id: params[:id])
      session.assign_attributes(params
        .except(:email, :password)
        .merge(
          last_active_at: DateTime.current,
          user_id: user.id
        )
      )
      session.save!
      session
    end

    def fetch(session_id)
      if session_id.present?
        cache_key = [:session, session_id]
        session = Rails.cache.fetch(cache_key, race_condition_ttl: 5.seconds, expires_in: 30.seconds) do
          Session.find_by(id: session_id)
        end
      end

      raise API::V1::Errors::Unauthorized, "Session does not exist or timed out." if session.nil?

      session
    end
  end
end
