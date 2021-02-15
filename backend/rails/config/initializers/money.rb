# frozen_string_literal: true

# Message from the Money Gem, as of version 6.13.7
#   The default rounding mode will change from `ROUND_HALF_EVEN` to `ROUND_HALF_UP` in the ' \
#   'next major release. Set it explicitly using `Money.rounding_mode=` to avoid potential problems.'
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
