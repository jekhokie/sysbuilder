Rails.application.routes.draw do
  root 'home#index'

  post '/assign_component' => 'component#assign'
  post '/build_summary'    => 'component#build_summary'
end
