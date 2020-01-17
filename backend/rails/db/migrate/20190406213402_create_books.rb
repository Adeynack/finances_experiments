# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books, id: :uuid do |t|
      t.timestamps
      t.string :name, null: false
      t.belongs_to :owner, type: :uuid, null: false, foreign_key: { to_table: :users }

      t.index [:name, :owner_id], unique: true
    end
  end
end
