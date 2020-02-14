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

class Session < ApplicationRecord
  belongs_to :user

  EXPIRES_AFTER = 20.minutes

  scope :expired, -> do
    where("sessions.last_active_at < ? OR sessions.expired_at < ?", EXPIRES_AFTER.ago, DateTime.current)
  end

  before_save do
    self.last_active_at ||= DateTime.current
    self.user_agent = user_agent&.truncate(255)
  end

  def valid_until
    last_active_at + EXPIRES_AFTER
  end

  class << self
    def activate(params)
      session = Session.find_or_initialize_by id: params[:id]
      session.assign_attributes(params
        .except(:email, :password)
        .merge(last_active_at: DateTime.current))

      # If the email is part of the params, it means this is
      # during the creation of a session. Authenticate!
      params[:email].presence&.tap do |user_email|
        user = User.find_by(email: user_email)
        raise API::V1::Errors::Unauthorized, "Invalid credentials" unless user&.authenticate(params[:password])

        session.user = user
      end

      session.save!
      session
    end
  end
end
