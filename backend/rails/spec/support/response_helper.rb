# frozen_string_literal: true

module ResponseHelper
  def json
    @json ||= JSON.parse(response.body, object_class: OpenStruct)
  end
end

RSpec.configure do |config|
  config.include ResponseHelper
end
