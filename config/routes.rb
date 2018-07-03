Rails.application.routes.draw do
  get 'suggest', to: 'search#suggest'
  get 'search',  to: 'search#index'
  root to: 'artists#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
