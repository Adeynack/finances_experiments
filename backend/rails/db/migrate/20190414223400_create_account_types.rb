class CreateAccountTypes < ActiveRecord::Migration[6.0]
  # Following instruction on enums from https://naturaily.com/blog/ruby-on-rails-enum
  def up
    execute <<~SQL
      CREATE TYPE account_type AS ENUM(
        -- categories
        'expense',
        'income',
        -- accounts
        'other',
        'bank',
        'card',
        'investment',
        'asset',
        'liability',
        'loan'
      );
    SQL
  end

  def down
    execute <<~SQL
      DROP TYPE account_type;
    SQL
  end
end
