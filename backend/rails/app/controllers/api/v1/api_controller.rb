# frozen_string_literal: true

class API::V1::APIController < ApplicationController
  include Errorable

  def auth_token
    @auth_token ||= ActionController::HttpAuthentication::Token.token_and_options(request)&.first
  end
end
