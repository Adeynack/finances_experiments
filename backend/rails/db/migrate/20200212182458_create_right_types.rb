# frozen_string_literal: true

class CreateRightTypes < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      CREATE TYPE user_right_type AS ENUM(
        'own',
        'read',
        'write'
      );
    SQL
  end

  def down
    execute <<~SQL
      DROP TYPE user_right_type;
    SQL
  end
end
