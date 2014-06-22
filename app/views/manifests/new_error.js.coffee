$("#modal form#save-manifest #save-errors").html "<%= escape_javascript(render :template => 'manifests/new_error', :formats => [ :html ], :locals => { :manifest => @manifest }) %>"
