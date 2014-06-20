class ComponentController < ApplicationController
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

    render :template => 'component/assign', :formats => [ :html ], :layout => false
  end

  def change_provider
    provider              = params[:provider_name]
    compute_provider_list = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))
    @new_provider_options = compute_provider_list[provider.to_sym] unless compute_provider_list.nil?

    render :template => 'component/change_provider', :formats => [ :html ], :layout => false
  end

  def get_provider_info
    @provider_name        = params[:provider_name]
    compute_provider_list = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))
    @provider_info        = compute_provider_list[@provider_name.to_sym] unless compute_provider_list.nil?

    render :template => 'component/get_provider_info', :formats => [ :html ], :layout => false
  end

  def build_summary
    @component_json             = params[:component_json] || {}
    @component_json["provider"] = params[:provider] unless @component_json.blank?

    respond_to do |format|
      format.json { render :json => @component_json.to_json }
    end
  end
end
