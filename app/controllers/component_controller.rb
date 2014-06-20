class ComponentController < ApplicationController
  def assign
    @name     = params[:name]
    @category = params[:category]
    @tag      = params[:tag]
    @instance = params[:instance]

    render :template => 'component/assign', :formats => [ :html ], :layout => false
  end

  def build_summary
    @component_json = params[:component_json] || {}

    respond_to do |format|
      format.json { render :json => @component_json.to_json }
    end
  end
end
