# frozen_string_literal: true

module ResponseHelper
  attr_reader :current_session
  attr_reader :json

  def authenticate!(user)
    raise Error, "Already authenticated as #{current_session.user.email} (#{current_session.user.id})" if current_session.present?

    user = users(user) if user.is_a?(Symbol)
    @current_session = Session.create!(user: user)
  end

  [:get, :post, :patch, :delete].each do |method|
    define_method(method) do |action, **args|
      skip_auth = args.delete :skip_auth

      args[:headers] ||= {}.tap do |h|
        h["Authorization"] ||= "Bearer #{current_session.id}" if !skip_auth && current_session
        h["Content-Type"] ||= "application/json"
      end
      args[:params] = args[:params].to_json if args[:params].present?
      super(action, **args)
      @json = (response.body.presence&.then { |body| JSON.parse(body, object_class: OpenStruct) })
    end
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
