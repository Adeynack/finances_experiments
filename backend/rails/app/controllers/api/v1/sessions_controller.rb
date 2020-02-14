# frozen_string_literal: true

class API::V1::SessionsController < API::V1::APIController
  before_action :require_session, except: :create

  def create
    session = Session.authenticate_and_create(
      id: auth_token,
      email: params.require(:email),
      password: params.require(:password),
      user_agent: request.user_agent,
      ip: request.remote_ip
    )
    render json: session, status: :created
  end

  def show
    render json: session
  end
end
