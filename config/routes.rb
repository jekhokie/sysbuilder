Rails.application.routes.draw do
  root 'home#index'

  post '/assign_component' => 'component#assign'
  post '/build_summary'    => 'component#build_summary'
  post '/change_provider'  => 'component#change_provider'
end
