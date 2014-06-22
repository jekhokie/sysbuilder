$("#manifest-save-state").html "<span class='glyphicon glyphicon-ok-sign'></span> Saved"
$("#manifest-save-state").removeClass("btn-danger").addClass("btn-success")

$("#flash-box").html "<%= escape_javascript(render :partial => 'shared/flash_message', :locals => { :key => :success, :value => flash[:notice] }) %>"
$("#flash-message").delay(3000).fadeOut 200
