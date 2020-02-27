# frozen_string_literal: true

class SessionCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Session.expired.find_each do |s|
      s.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      Rails.logger.error "#{e.class}: #{e.message}"
    end
  end
end
