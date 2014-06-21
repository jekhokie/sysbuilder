ready = ->
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

# handle turbolinks rails 4 document ready
$(document).ready(ready)
$(document).on('page:load', ready)
