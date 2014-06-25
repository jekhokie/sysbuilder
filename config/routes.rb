Rails.application.routes.draw do
  root 'manifests#explore'

  # manifest explorer paths
  get 'explore', to: 'manifests#explore'

  # manifest builder paths
  get       'build',               to: 'manifests#build'
  post      'assign_component',    to: 'manifests#assign'
  post      'build_summary',       to: 'manifests#build_summary'
  post      'change_provider',     to: 'manifests#change_provider'
  post      'get_provider_info',   to: 'manifests#get_provider_info'
  post      '/manifests/new',      to: 'manifests#new'
  resource  :manifests,          only: [ :create ]
  resources :manifests,          only: [ :edit, :update ]

  # launch paths
  get 'launch', to: 'launches#index'
  resources :manifests, only: [ ] do
    member do
      get 'launch',     to: 'launches#launch'
      post 'provision', to: 'launches#provision'
    end
  end
end
