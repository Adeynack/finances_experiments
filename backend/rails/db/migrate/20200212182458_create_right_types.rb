# frozen_string_literal: true

class CreateRightTypes < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      CREATE TYPE user_access_level AS ENUM(
        'admin',
        'write',
        'read'
      );
    SQL
  end

  def down
    execute <<~SQL
      DROP TYPE user_access_level;
    SQL
  end
end
