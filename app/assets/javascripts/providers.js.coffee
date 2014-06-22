providersReady = ->
  # prompt user when they change the provider to confirm the change
  $("#provider").livequery ->
    $(this).change ->
      $("#modal .modal-close").html ""
      $("#modal .modal-title").html "WARNING: Provider Change"
      $("#modal .modal-body").html  "<h4>Are you sure you wish to change the provider?<br/>This will reset all VResource settings within the manifest.</h4><input type='hidden' name='selected-provider' value='" + $(this).val() + "'/>"
      $("#modal .modal-footer").html "<button type='button' data-dismiss='modal' class='btn btn-warning' id='confirm-change-provider'>Confirm</button><button type='button' data-dismiss='modal' class='btn btn-primary' id='decline-change-provider'>Cancel</button>"
      $("#modal").modal
        backdrop: "static"
        keyboard: false

  # catch when the user submits their response to reject changing the provider
  $("#decline-change-provider").livequery ->
    $(this).click ->
      $("#provider").val $("#provider").attr("data-selected")

  # catch when the user submits their response to the confirm for changing provider
  $("#confirm-change-provider").livequery ->
    $(this).click ->
      providerName = $(this).closest("#modal").find("input[name='selected-provider']").val()
      $("#provider").attr("data-selected", providerName)

      $.ajax $("#provider").attr("data-change-path"),
        context: this
        type:    "POST"
        data:
          provider_name: providerName
        success: (response) ->
          $.each $(".provider-compute-resources"), (index, value) ->
            $(value).empty().append $(response)
          $("#dc-build-form").find("input[name='provider']").val $("#provider").val()
      return

  # show information about provider when requested
  $("#show-provider-specs").livequery ->
    $(this).click ->
      $.ajax $(this).attr("data-info-path"),
        context: this
        type:    "POST"
        data:
          provider_name: $("#provider").val()
        success: (response) ->
          $("#modal .modal-close").html ""
          $("#modal .modal-title").html "Provider Information"
          $("#modal .modal-body").html  $(response)
          $("#modal .modal-footer").html "<button type='button' class='btn btn-default' data-dismiss='modal'>Close</button>"
          $("#modal").modal
            backdrop: "static"
            keyboard: false
      return

# handle turbolinks rails 4 document ready
$(document).ready(providersReady)
$(document).on('page:load', providersReady)
