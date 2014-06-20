$(document).ready ->
  # handle removing elements when the destroy button is clicked
  $(".component-destroy").livequery ->
    $(this).click ->
      event.preventDefault

      headingDomId   = $(this).closest(".component-list").attr("id").replace("-container", "-heading")
      countElement   = $(this).closest("form").find("#" + headingDomId).find(".component-count")
      containerDomId = $(this).closest(".component-list").attr("id")

      $(this).closest(".assigned-component").remove()
      $(countElement).html $("#" + containerDomId).find(".assigned-component").size()
      return
