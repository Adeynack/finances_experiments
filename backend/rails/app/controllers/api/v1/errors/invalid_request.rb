# frozen_string_literal: true

class API::V1::Errors::InvalidRequest < API::V1::Errors::Base
  def status
    400
  end

  def title
    "Invalid Request"
  end
end
