$(".progress-indicator").css("visibility", "").css("display", "")
$("#build-instance-channel").html "<%= escape_javascript(render :template => 'launches/provision_channel', :formats => [ :html ], :locals => { :build_instance => @build_instance }) %>"
