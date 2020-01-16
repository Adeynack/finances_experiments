# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  namespace :api, path: "", constraints: { format: ["json"] }, defaults: { format: :json } do
    namespace :v1 do
      resources :books
    end
    root to: "api#root"
  end
end
