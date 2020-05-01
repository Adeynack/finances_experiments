# frozen_string_literal: true

class CreateBookRights < ActiveRecord::Migration[6.0]
  def change
    create_table :book_rights, id: :uuid do |t|
      t.timestamps
      t.belongs_to :book, null: true, type: :uuid
      t.belongs_to :user, null: false, type: :uuid
      t.column :access, :user_access_level, null: false

      t.index [:book_id, :user_id], unique: true
    end
  end
end
