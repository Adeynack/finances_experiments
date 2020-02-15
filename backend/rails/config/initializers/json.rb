# frozen_string_literal: true

ActiveSupport::JSON::Encoding.time_precision = 0

class BigDecimal
  def as_json(*)
    to_f
  end
end
