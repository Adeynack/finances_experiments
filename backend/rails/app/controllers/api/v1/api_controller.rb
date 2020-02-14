# frozen_string_literal: true

class API::V1::APIController < ApplicationController
  include Errorable

  protected

  def require_session
    raise API::V1::Errors::Unauthorized, "A session is required." unless session
  end

  def session
    @session ||= Session.fetch(auth_token) if auth_token.present?
  end

  def auth_token
    @auth_token ||= ActionController::HttpAuthentication::Token.token_and_options(request)&.first
  end
end
