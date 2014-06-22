Rails.application.routes.draw do
  root 'manifests#explore'

  # manifest explorer paths
  get 'explore', to: 'manifests#explore'

  # manifest builder paths
  get  'build',               to: 'manifests#build'
  post 'assign_component',    to: 'manifests#assign'
  post 'build_summary',       to: 'manifests#build_summary'
  post 'change_provider',     to: 'manifests#change_provider'
  post 'get_provider_info',   to: 'manifests#get_provider_info'
  resource :manifests,      only: [ :new, :create ]
  resources :manifests,     only: [ :update ]
end
