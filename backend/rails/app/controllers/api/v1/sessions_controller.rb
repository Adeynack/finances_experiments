# frozen_string_literal: true

class API::V1::SessionsController < API::V1::APIController
  def create
    p = session_params(creating: true).merge!(id: auth_token)
    session = Session.activate(p)
    render json: session, status: :created
  end

  def show
    session = Session.activate(p)
    render json: session
  end

  private

  def session_params(creating:)
    p = {
      user_agent: request.user_agent,
      ip: request.remote_ip
    }
    if creating
      email = params.require(:email),
              password = params.require(:password)
      p = p.merge(email: email, password: password)
    end
    p
  end
end
