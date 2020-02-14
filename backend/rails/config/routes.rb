# frozen_string_literal: true

# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#            api_v1_session GET    /v1/session(.:format)                                                                    api/v1/sessions#show {:format=>["json"]}
#                           PATCH  /v1/session(.:format)                                                                    api/v1/sessions#update {:format=>["json"]}
#                           PUT    /v1/session(.:format)                                                                    api/v1/sessions#update {:format=>["json"]}
#                           DELETE /v1/session(.:format)                                                                    api/v1/sessions#destroy {:format=>["json"]}
#                           POST   /v1/session(.:format)                                                                    api/v1/sessions#create {:format=>["json"]}
#              api_v1_books GET    /v1/books(.:format)                                                                      api/v1/books#index {:format=>["json"]}
#                           POST   /v1/books(.:format)                                                                      api/v1/books#create {:format=>["json"]}
#               api_v1_book GET    /v1/books/:id(.:format)                                                                  api/v1/books#show {:format=>["json"]}
#                           PATCH  /v1/books/:id(.:format)                                                                  api/v1/books#update {:format=>["json"]}
#                           PUT    /v1/books/:id(.:format)                                                                  api/v1/books#update {:format=>["json"]}
#                           DELETE /v1/books/:id(.:format)                                                                  api/v1/books#destroy {:format=>["json"]}
#                  api_root GET    /                                                                                        api/api#root {:format=>:json}
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  namespace :api, path: "", constraints: { format: ["json"] }, defaults: { format: :json } do
    namespace :v1 do
      resource :session
      resources :books
    end
    root to: "api#root"
  end
end
