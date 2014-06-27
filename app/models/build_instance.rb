class BuildInstance < ActiveRecord::Base
  belongs_to :manifest

  def configuration
    manifest.configuration
  end

  def vplatform
    manifest.vplatform
  end
end
