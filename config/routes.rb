Rails.application.routes.draw do
  root 'manifests#build'

  # manifest builder paths
  post '/assign_component'  => 'manifests#assign'
  post '/build_summary'     => 'manifests#build_summary'
  post '/change_provider'   => 'manifests#change_provider'
  post '/get_provider_info' => 'manifests#get_provider_info'
end
