Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'home#index'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  get '/playlist', to: 'playlists#show_mine'
  put '/playlist/refresh', to: 'playlists#refresh'

  get '/preferences', to: 'preferences#edit'
  put '/preferences', to: 'preferences#update'
  delete '/users/:id', to: 'preferences#delete_user', as: 'user'

  get '/start', to: 'start_page#start'
  put '/start', to: 'start_page#save'

  get '/charts', to: 'mood_ratings#index_mine'
  post '/mood-ratings', to: 'mood_ratings#create'
  get '/admin', to: 'admin#index'

end
