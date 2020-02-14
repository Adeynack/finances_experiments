# frozen_string_literal: true

Rails.cache.logger = Rails.logger if Rails.env.development?
