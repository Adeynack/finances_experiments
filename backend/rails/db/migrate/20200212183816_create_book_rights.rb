# frozen_string_literal: true

class CreateBookRights < ActiveRecord::Migration[6.0]
  def change
    create_table :book_rights, id: :uuid do |t|
      t.timestamps
      t.belongs_to :book, null: true
      t.belongs_to :user, null: false
      t.column :right, :user_right_type, null: false

      t.index [:book_id, :user_id, :right], unique: true
    end
  end
end
