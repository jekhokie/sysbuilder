class Manifest < ActiveRecord::Base
  serialize :configuration, JSON

  validates :name,          presence: true, uniqueness: true
  validates :configuration, presence: true
end
