$("#modal").modal "hide"
$("#flash-box").html "<%= escape_javascript(render :partial => 'shared/flash_message', :locals => { :key => :success, :value => flash[:notice] }) %>"
$("#flash-message").delay(3000).fadeOut 200
