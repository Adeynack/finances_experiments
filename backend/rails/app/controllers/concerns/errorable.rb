# frozen_string_literal: true

module Errorable
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing do |error|
      render_error(API::V1::Errors::InvalidRequest.new(error.message))
    end

    rescue_from API::V1::Errors::Base do |error|
      log_exception(error)
      render_error(error, error.backtrace)
    end
  end

  protected

  def log_exception(error)
    return if Rails.env.test?
    return if error.is_a?(ActiveRecord::RecordNotFound)

    Rails.logger.error "[API] Error: #{error.class}: #{error.message}"
  end

  def render_error(error, trace = nil)
    error_json = error.to_h.tap do |hash|
      hash.merge!(trace: trace) if Rails.env.development? || Rails.env.test?
    end

    expires_now

    render(
      status: error.status,
      json: error_json,
      scope: nil # error responses don't need a scope
    )
  end
end
