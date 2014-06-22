buildOptionsReady = ->
  # create the build summary by passing information back to the server
  $("#generate-build-summary-json").livequery ->
    $(this).click (event) ->
      event.preventDefault()

      submitForm = $("form#dc-build-form")

      $.ajax $(submitForm).attr("action"),
        context: this
        type:    "POST"
        data: $(submitForm).serialize()
        dataType: "json"
        success: (response, status, xhr) ->
          responseType = xhr.getResponseHeader("content-type") || ""

          if responseType.indexOf('json') > -1
            jsonContent = $("<pre></pre>").html(JSON.stringify(response, undefined, 2))
            $("#modal .modal-close").html "<button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>"
            $("#modal .modal-title").html  "Data Center Build Manifest Specification"
            $("#modal .modal-body").html   $(jsonContent)
            $("#modal .modal-footer").html "<button type='button' class='btn btn-default' data-dismiss='modal'>Close</button>"
            $("#modal").modal
              backdrop: "static"
              keyboard: false
          else
            alert "An error has occurred - unexpected response data type"
        error: (response) ->
          alert "An error has occurred - please check the server logs"

      return

  # handle the user opting to save the manifest they created
  # JS is required in order to gather the form data for the manifest
  $("#save-manifest").livequery ->
    $(this).click (event) ->
      event.preventDefault()

      submitForm = $("form#dc-build-form")

      if $(submitForm).find(".assigned-component").size() < 1
        alert "Please assign at least 1 component before attempting to save the manifest."
      else
        $.ajax $(this).attr("data-save-path"),
          context: this
          type:    "GET"
          data: $(submitForm).serialize()
          success: (response) ->
            $("#modal .modal-close").html "<button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>"
            $("#modal .modal-title").html "Save Manifest"
            $("#modal .modal-body").html  $(response)
            $("#modal .modal-footer").html "<button type='button' class='btn btn-success' onclick='$(\"form#save-manifest\").submit();'>Save</button><button type='button' class='btn btn-danger' data-dismiss='modal'>Cancel</button>"
            $("#modal").modal
              backdrop: "static"
              keyboard: false
          error: (response) ->
            alert "An error has occurred - please check the server logs"

      return

# handle turbolinks rails 4 document ready
$(document).ready(buildOptionsReady)
$(document).on('page:load', buildOptionsReady)
