class Manifest < ActiveRecord::Base
  serialize :configuration, JSON
end
