# frozen_string_literal: true

class API::V1::Errors::Base < StandardError
  attr_reader :options

  def initialize(message, options = {})
    @options = options
    super(message)
  end

  def to_h
    {
      title: title,
      status: status,
      detail: detail
    }.merge(options)
  end

  def status
    # Not implemented
  end

  def title
    # Not implemented
  end

  def detail
    message.capitalize if message.present?
  end
end
