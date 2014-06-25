class LaunchesController < ApplicationController
  def index
    @manifests = Manifest.all
  end

  def launch
    get_manifest
  end

  def provision
    get_manifest

    # TODO: Kick off the data center provision based on the manifest.configuration

    render :formats => [ :js ]
  end

  private

  def get_manifest
    @manifest = Manifest.find params[:id]
  end
end
