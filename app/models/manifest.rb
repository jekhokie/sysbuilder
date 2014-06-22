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
    JSON.parse(self.configuration)["provider"]
  end
end
