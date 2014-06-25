$("#launch-status").html "<%= escape_javascript(render :template => 'launches/launch', :formats => [ :html ], :locals => { :manifest => @manifest }) %>"
