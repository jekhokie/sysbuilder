$(document).ready ->
  # create the build summary by passing information back to the server
  $("#generate-build-summary-json").click (event) ->
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
          $("#modal .modal-title").html "Datacenter Build"
          $("#modal .modal-body").html $(jsonContent)
          $("#modal").modal 'show'
        else
          alert "An error has occurred - unexpected response data type"
      error: (response) ->
        alert "An error has occurred - please check the server logs"

    return
