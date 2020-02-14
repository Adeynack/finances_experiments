# frozen_string_literal: true

module ResponseHelper
  def json
    @json ||= JSON.parse(response.body, object_class: OpenStruct)
  end

  def pjson
    msg = response.body.presence&.then { |body| JSON.pretty_generate(JSON.parse(body)) }
    puts(msg || "<nil>")
  end

  def pbody
    puts response.body
  end
end

RSpec.configure do |config|
  config.include ResponseHelper
end
