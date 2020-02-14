# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions, id: :uuid do |t|
      t.timestamps
      t.belongs_to :user, type: :uuid, null: false
      t.datetime :last_active_at
      t.string :user_agent
      t.string :ip

      t.index :last_active_at
    end
  end
end
