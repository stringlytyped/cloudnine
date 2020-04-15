Rails.application.routes.draw do
 
  root 'home#index'
   get 'home/index'
   post 'home/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'dashboard#index'
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :playlists

  get '/playlist', to: 'playlists#show_mine'

end
