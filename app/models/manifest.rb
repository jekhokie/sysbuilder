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

  def vplatform
    self.configuration.nil? ? "" : JSON.parse(self.configuration)["provider"]
  end

  def get_versions_for(name)
    component_list = YAML::load(File.open(File.join(Rails.root, 'config/components.yml')))
    component_list.deep_fetch(name.to_sym)[:versions]
  end
end
