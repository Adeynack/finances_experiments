# frozen_string_literal: true

class SessionCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Session.expired.find_each do |s|
      s.destroy!
    rescue ActiveRecord::DeleteRestrictionError => error
      Rails.logger.error "#{error.class}: #{error.message}"
    end
  end
end
