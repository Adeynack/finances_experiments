# frozen_string_literal: true

# == Route Map
#
#                    Prefix Verb URI Pattern                                                                              Controller#Action
#                       erd      /erd                                                                                     Erd::Engine
#            graphiql_rails      /graphiql                                                                                GraphiQL::Rails::Engine {:graphql_path=>"/graphql"}
#                   graphql POST /graphql(.:format)                                                                       graphql#execute
#               sidekiq_web      /sidekiq                                                                                 Sidekiq::Web
#        rails_service_blob GET  /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET  /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET  /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT  /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
#
# Routes for Erd::Engine:
#         GET  /                  erd/erd#index
#         PUT  /                  erd/erd#update
# migrate PUT  /migrate(.:format) erd/erd#migrate
#    root GET  /                  erd/erd#index
#
# Routes for GraphiQL::Rails::Engine:
#        GET  /           graphiql/rails/editors#show

require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  #
  # GraphQL
  #
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  post "/graphql", to: "graphql#execute"
  #
  # Sidekiq
  #
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # TODO: Check how that works with security.
      User.find_by(email: username)&.authenticate(password)
    end
  end
  mount Sidekiq::Web => "/sidekiq"
end
