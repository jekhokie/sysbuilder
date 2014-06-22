buildReady = ->
  # handle component draggable objects into the category lists
  $(".draggable").livequery ->
    $(this).draggable
      cursor:   "move"
      revert:   "invalid"
      helper: (event) ->
        $("<div class='dc-component'><div class='title'>" + $(this).text() + "</div>")

  # change the saved state to "not saved"
  renderNotSaved = ->
    $("#manifest-save-state").html "<span class='glyphicon glyphicon-info-sign'></span> Not Saved"
    $("#manifest-save-state").removeClass("btn-success").addClass("btn-danger")

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
              # indicate not saved state
              renderNotSaved()

              # insert the element into the container
              elementId          = $(this).attr("id").replace("-heading", "").concat("-container")
              componentContainer = $(this).closest(".panel").find("#" + elementId)
              appendObject       = $(obj).css("display", "none")

              $(componentContainer).append $(appendObject)[0]
              $(appendObject).slideDown()

              # update the number of components for the container type
              numComponents = $(componentContainer).find(".assigned-component").size()
              $(this).find(".component-count").html numComponents
          return
      i++

  # ensure that any time a form input is changed, the manifest is not saved
  $("select[class='component-version-select'], select[class='provider-compute-resources']").livequery ->
    $(this).change ->
      renderNotSaved()

  # ensure that any time a component is removed, the manifest is not saved
  $("button.component-destroy").livequery ->
    $(this).click ->
      renderNotSaved()

  # prompt the user to save changes if they attempt to navigate away with un-saved changes
  $(window).bind "beforeunload", ->
    if window.location.pathname.match(/^(\/build|.*\/edit)$/)
      if $("#manifest-save-state").hasClass("btn-danger") and $("#dc-build-form").find(".assigned-component").size() > 0
        "You have unsaved changes - are you sure you wish to navigate away?"

# handle turbolinks rails 4 document ready
$(document).ready(buildReady)
$(document).on('page:load', buildReady)
