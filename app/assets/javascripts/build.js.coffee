buildReady = ->
  $(".draggable").livequery ->
    $(this).draggable
      cursor:   "move"
      revert:   "invalid"
      helper: (event) ->
        $("<div class='dc-component'><div class='title'>" + $(this).text() + "</div>")

  # build out droppable handling dynamically
  componentArray = []
  $.each $("#component-container").find(".panel-heading"), (index, value) ->
    componentArray.push($(value).attr("id").replace("-heading", ""))
    return

  arrayLength = componentArray.length
  i = 0

  while i < arrayLength
    $("#" + componentArray[i] + "-heading").livequery ->
      $(this).droppable
        accept:      "#" + componentArray[i] + "-component"
        activeClass: "ui-state-active"
        hoverClass:  "ui-state-hover"
        drop: (event, ui) ->
          $.ajax $(ui.draggable).data("path"),
            context: this
            type:    "POST"
            data:
              name:     $(ui.draggable).text()
              category: $(this).attr("id").replace("-heading", "")
              tag:      $(ui.draggable).data("tag")
              instance: $("#" + $(this).attr("id").replace("-heading", "-container")).find(".assigned-component").size() + 1
              versions: $(ui.draggable).data("versions")
              provider: $("#provider").val()
            success: (obj) ->
              # insert the element into the container
              elementId          = $(this).attr("id").replace("-heading", "").concat("-container")
              componentContainer = $(this).closest(".panel").find("#" + elementId)
              $(componentContainer).append $(obj)[0]

              # update the number of components for the container type
              numComponents = $(componentContainer).find(".assigned-component").size()
              $(this).find(".component-count").html numComponents
          return
      i++

# handle turbolinks rails 4 document ready
$(document).ready(buildReady)
$(document).on('page:load', buildReady)
