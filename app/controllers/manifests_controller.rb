class ManifestsController < ApplicationController
  #vvv explore actions vvv#
  def explore
    @manifests = Manifest.all
  end

  #vvv build actions vvv#
  def build
    @category_list     = YAML::load(File.open(File.join(Rails.root, 'config/categories.yml')))
    @component_list    = YAML::load(File.open(File.join(Rails.root, 'config/components.yml')))
    @compute_providers = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))
  end

  def assign
    @name              = params[:name]
    @category          = params[:category]
    @tag               = params[:tag]
    @instance          = params[:instance]
    @versions          = params[:versions].split(",")

    # determine available virtual resources based on the provider selected
    provider              = params[:provider]
    @compute_providers    = []
    compute_provider_list = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))

    unless compute_provider_list.nil?
      @compute_providers = compute_provider_list[provider.to_sym]
    end

    render :template => 'manifests/assign', :formats => [ :html ], :layout => false
  end

  def change_provider
    provider              = params[:provider_name]
    compute_provider_list = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))
    @new_provider_options = compute_provider_list[provider.to_sym] unless compute_provider_list.nil?

    render :template => 'manifests/change_provider', :formats => [ :html ], :layout => false
  end

  def get_provider_info
    @provider_name        = params[:provider_name]
    compute_provider_list = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))
    @provider_info        = compute_provider_list[@provider_name.to_sym] unless compute_provider_list.nil?

    render :template => 'manifests/get_provider_info', :formats => [ :html ], :layout => false
  end

  def build_summary
    get_component_json_and_provider

    respond_to do |format|
      format.json { render :json => @component_json.to_json }
    end
  end

  def new
    get_component_json_and_provider

    @manifest               = Manifest.new
    @manifest.configuration = JSON.dump @component_json

    render :template => 'manifests/new', :formats => [ :html ], :layout => false
  end

  def create
    @manifest = Manifest.new manifest_params

    if @manifest.save
      flash[:notice] = "Manifest saved successfully!"
      render
    else
      render :template => 'manifests/new_error', :formats => [ :js ]
    end

    flash.discard
  end

  private

  def get_component_json_and_provider
    @component_json             = params[:component_json] || {}
    @component_json["provider"] = params[:provider] unless @component_json.blank?
  end

  def manifest_params
    params.require(:manifest).permit(:name, :configuration)
  end
end
