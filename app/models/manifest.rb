class Manifest < ActiveRecord::Base
  serialize :configuration, JSON

  validates :name,          presence: true, uniqueness: true
  validates :configuration, presence: true

  def num_vresources
    total_vresources = 0
    JSON.parse(self.configuration)["manifest"].each do |component, elements|
      total_vresources += elements.keys.count
    end

    total_vresources
  end

  def get_versions_for(name)
    component_list = YAML::load(File.open(File.join(Rails.root, 'config/components.yml')))
    component_list.deep_fetch(name.to_sym)[:versions]
  end

  def vplatform
    configuration.nil? ? "" : JSON.parse(configuration)["provider"]
  end

  def hourly_cost
    configuration.nil? ? "0.000" : JSON.parse(configuration)["costs"]["hourly"]
  end

  def monthly_cost
    configuration.nil? ? "0.000" : JSON.parse(configuration)["costs"]["monthly"]
  end

  def yearly_cost
    configuration.nil? ? "0.000" : JSON.parse(configuration)["costs"]["yearly"]
  end
end
