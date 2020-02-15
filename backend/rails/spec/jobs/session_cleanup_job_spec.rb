# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionCleanupJob, type: :job do
  fixtures :users

  it "does not do anything when no session exist" do
    expect(Session.count).to eq 0
    SessionCleanupJob.perform_now
  end

  it "does not delete a session that is still valid" do
    freeze_time
    session_id = Session.create!(user: users(:joe)).id
    travel Session::EXPIRES_AFTER - 1.second
    SessionCleanupJob.perform_now
    expect(Session.find_by(id: session_id)).not_to be_nil
  end

  it "deletes a session that is too old" do
    freeze_time
    session_id = Session.create!(user: users(:joe)).id
    travel Session::EXPIRES_AFTER + 1.second
    SessionCleanupJob.perform_now
    expect(Session.find_by(id: session_id)).to be_nil
  end
end
