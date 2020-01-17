# frozen_string_literal: true

class CreateCurrencies < ActiveRecord::Migration[6.0]
  def change
    create_table :currencies, id: :uuid do |t|
      t.timestamps
      t.string :code, comment: "ISO-4217 Code (https://en.wikipedia.org/wiki/ISO_4217)"
      t.belongs_to :book, type: :uuid, null: true, comment: "Known currencies are general and do not belong to any book (null); custom currencies belong to a specific book."
      t.string :name, null: false
      t.string :prefix, comment: "Text or symbol to prefix when displaying an amount in this currency."
      t.string :suffix, comment: "Text or symbol to suffix when displaying an amount in this currency."

      t.index [:code, :book_id], unique: true
    end
  end
end
