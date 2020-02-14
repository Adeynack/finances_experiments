# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::SessionsController do
  fixtures :users

  describe "POST /api/v1/sessions" do
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

      post api_v1_session_path, params: { email: "joe@foobar.com", password: "foobar" }
      expect(response).to have_http_status :created

      joe = users(:joe)
      user_sessions = Session.where(user_id: joe.id)
      expect(user_sessions.count).to eq 1
      created_session = user_sessions[0]

      expect(json).to have_attributes(
        token: created_session.id,
        user_id: joe.id
      )
      expect(DateTime.parse(json.valid_until).utc).to eq 20.minutes.from_now
    end
  end
end
