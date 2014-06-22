$("#flash-box").html "<%= escape_javascript(render :partial => 'shared/flash_message', :locals => { :key => :error, :value => flash[:error] }) %>"
$("#flash-message").delay(3000).fadeOut 200
