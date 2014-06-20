class HomeController < ApplicationController
  def index
    @category_list  = YAML::load(File.open(File.join(Rails.root, 'config/categories.yml')))
    @component_list = YAML::load(File.open(File.join(Rails.root, 'config/components.yml')))
  end
end
