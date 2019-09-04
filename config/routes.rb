Rails.application.routes.draw do
  root to: 'home#index'
  
  resources :episodes
  patch '/episodes/:id/remove_hosts_guests', to: 'episodes#remove_hosts_guests', as: :remove_hosts_guests
  patch '/episodes/:id/add_part', to: 'episodes#add_part', as: :add_part
  patch '/episodes/:id/remove_part/:index', to: 'episodes#remove_part', as: :remove_part
  patch '/episodes/:id/add_more', to: 'episodes#add_more', as: :add_more
  patch '/episodes/:id/remove_link', to: 'episodes#remove_link', as: :remove_link
  patch '/episodes/:id/remove_picture', to: 'episodes#remove_picture', as: :remove_picture

  resources :hosts
  resources :guests
  resources :settings
  resources :stat_object, only: [:create, :update]
  patch '/stat_objects/init', to: 'statistics#init', as: :statistics_init
  patch '/stat_objects/tick_media', to: 'statistics#tick_media', as: :statistics_tick_media

  get '/dashboard',           to: 'dashboard#index',    as: :dashboard
  get '/dashboard/episodes',  to: 'dashboard#episodes', as: :dashboard_episodes
  get '/dashboard/hosts',     to: 'dashboard#hosts',    as: :dashboard_hosts
  get '/dashboard/guests',    to: 'dashboard#guests',   as: :dashboard_guests

  devise_for :admin, only: :sessions, controllers: { :sessions => "sessions" }

  devise_scope :admin do
    resource :sessions,
      only: [:new, :create],
      path: '/admin',
      path_names: { new: '/', create: '/' },
      controller: 'sessions',
      as: :admin_sign_in
  end
end
