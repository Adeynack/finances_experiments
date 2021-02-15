# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.timestamps
      t.string :email, null: false
      t.string :display_name, null: false
      t.string :password_digest, null: false

      t.index :email, unique: true
      t.index :display_name
    end
  end
end
