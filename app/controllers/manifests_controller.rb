class ManifestsController < ApplicationController
  #vvv explore actions vvv#
  def explore
    @manifests = Manifest.all
  end

  #vvv build actions vvv#
  def build
    @manifest = Manifest.new
    get_category_component_compute_lists
  end

  def assign
    @name     = params[:name]
    @category = params[:category]
    @tag      = params[:tag]
    @instance = params[:instance]
    @versions = params[:versions].split(",")
    @provider = params[:provider]

    get_compute_resources

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
    get_hourly_and_monthly_and_yearly_cost

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

  def edit
    @manifest              = Manifest.find(params[:id])
    manifest_configuration = JSON.parse(@manifest.configuration)
    @manifest_json         = manifest_configuration["manifest"]
    @provider              = manifest_configuration["provider"]

    get_category_component_compute_lists
    get_compute_resources

    render :action => 'build'
  end

  def update
    get_component_json_and_provider

    @manifest               = Manifest.find params[:id]
    @manifest.configuration = JSON.dump(@component_json)

    if @manifest.save
      flash[:notice] = "Manifest saved successfully!"
      render
    else
      flash[:error] = "Manifest could not be saved - please check server logs."
      render :template => 'manifests/update_error', :formats => [ :js ], :locals => { :manifest => @manifest }
    end

    flash.discard
  end

  private

  def get_component_json_and_provider
    @component_json             = params[:component_json] || { :manifest => {} }
    @component_json["provider"] = params[:provider]
  end

  def get_hourly_and_monthly_and_yearly_cost
    hourly_cost       = 0.000
    compute_providers = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))

    unless @component_json["manifest"].nil?
      @component_json["manifest"].each do |manifest, category_attrs|
        category_attrs.each do |component, component_attrs|
          hourly_cost += compute_providers[params[:provider].to_sym][component_attrs["vresource"].to_sym][:cost].to_f
        end
      end
    end

    # calculate monthly cost based on days in this month * 24 hours per day
    monthly_cost  = hourly_cost  * 24.0 * 30
    yearly_cost   = monthly_cost * 12.0

    @component_json["hourly_cost"]  = hourly_cost
    @component_json["monthly_cost"] = sprintf("%.4f" % monthly_cost)
    @component_json["yearly_cost"]  = sprintf("%.4f" % yearly_cost)
  end

  def get_compute_resources
    # determine available virtual resources based on the provider selected
    @compute_resources = []
    compute_list       = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))

    unless compute_list.nil?
      @compute_resources = compute_list[@provider.to_sym]
    end
  end

  def manifest_params
    params.require(:manifest).permit(:name, :configuration)
  end

  def get_category_component_compute_lists
    @category_list     = YAML::load(File.open(File.join(Rails.root, 'config/categories.yml')))
    @component_list    = YAML::load(File.open(File.join(Rails.root, 'config/components.yml')))
    @compute_providers = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))
  end
end
