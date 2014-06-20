class HomeController < ApplicationController
  def index
    @category_list     = YAML::load(File.open(File.join(Rails.root, 'config/categories.yml')))
    @component_list    = YAML::load(File.open(File.join(Rails.root, 'config/components.yml')))
    @compute_providers = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))
  end
end
