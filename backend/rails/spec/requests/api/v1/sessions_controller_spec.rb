# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::SessionsController do
  fixtures :users

  describe "POST /api/v1/session" do
    it "fails if no email is provided" do
      post api_v1_session_path, params: {}
      expect(response).to have_http_status :bad_request
    end

    it "fails if no password is provided" do
      post api_v1_session_path, params: { email: "joe@foobar.com" }
      expect(response).to have_http_status :bad_request
    end

    it "fails with Unauthorized if credentials are invalid" do
      post api_v1_session_path, params: { email: "joe@foobar.com", password: "wrong password" }
      expect(response).to have_http_status :unauthorized
    end

    it "creates a session when the email and password match" do
      freeze_time

      post api_v1_session_path, params: { email: "joe@foobar.com", password: "joe" }
      expect(response).to have_http_status :created

      joe = users(:joe)
      user_sessions = Session.where(user_id: joe.id)
      expect(user_sessions.count).to eq 1
      created_session = user_sessions[0]

      expect(json).to have_attributes(
        token: created_session.id,
        user_id: joe.id,
        valid_until: 20.minutes.from_now
      )
    end
  end

  describe "GET /api/v1/session" do
    it "fails with Unauthorized if no session is provided" do
      get api_v1_session_path
      expect(response).to have_http_status :unauthorized
      expect(json.detail).to eq "A session is required."
    end

    it "fails with Unauthorized when the session does not exist" do
      get api_v1_session_path, headers: { "Authorization" => "Bearer I_DO_NOT_EXIST" }
      expect(response).to have_http_status :unauthorized
      expect(json.detail).to eq "Session does not exist or timed out."
    end

    it "shows the session when it exists" do
      freeze_time
      joe = users(:joe)
      session = Session.create user: joe

      get api_v1_session_path, headers: { "Authorization" => "Bearer #{session.id}" }
      expect(response).to have_http_status :ok
      expect(json).to have_attributes(
        token: session.id,
        user_id: joe.id,
        valid_until: 20.minutes.from_now
      )
    end
  end

  describe "DELETE /api/v1/session" do
    it "fails with Unauthorized if no session is provided" do
      delete api_v1_session_path
      expect(response).to have_http_status :unauthorized
      expect(json.detail).to eq "A session is required."
    end

    it "fails with Unauthorized when the session does not exist" do
      delete api_v1_session_path, headers: { "Authorization" => "Bearer I_DO_NOT_EXIST" }
      expect(response).to have_http_status :unauthorized
      expect(json.detail).to eq "Session does not exist or timed out."
    end

    it "deletes the session when it exists" do
      joe = users(:joe)
      session = Session.create user: joe

      delete api_v1_session_path, headers: { "Authorization" => "Bearer #{session.id}" }
      expect(response).to have_http_status :no_content
      expect(response.body).to eq ""
      expect(Session.find_by(id: session.id)).to be_nil
    end
  end
end
