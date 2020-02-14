# frozen_string_literal: true

class API::V1::Errors::Unauthorized < API::V1::Errors::Base
  def status
    401
  end

  def title
    "Unauthorized Request"
  end
end
