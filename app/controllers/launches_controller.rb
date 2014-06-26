class LaunchesController < ApplicationController
  def index
    @manifests = Manifest.all
  end

  def launch
    get_manifest
  end

  def provision
    get_manifest

    # create the build with the associated channel for this manifest
    @build_instance         = @manifest.build_instances.new
    @build_instance.channel = "/build_status/#{rand(1000000)}"
    @build_instance.save

    # kick of the build asynchronously
    Thread.new do
      Provision.start @build_instance
      join
    end

    render :formats => [ :js ]
  end

  private

  def get_manifest
    @manifest = Manifest.find params[:id]
  end
end
