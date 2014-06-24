buildReady = ->
  # handle component draggable objects into the category lists
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
              # indicate not saved state
              renderNotSaved()

              # insert the element into the container
              elementId          = $(this).attr("id").replace("-heading", "").concat("-container")
              componentContainer = $(this).closest(".panel").find("#" + elementId)
              appendObject       = $(obj).css("display", "none")

              $(componentContainer).append $(appendObject)[0]
              $(appendObject).slideDown()

              # update the number and cost of components for the container type
              totalComponents = $(componentContainer).find(".assigned-component")
              numComponents = $(totalComponents).size()
              $(this).find(".component-count").html numComponents

              # update the total cost for the container type
              calculateCosts()
          return
      i++

  # ensure that any time a form input is changed, the manifest is not saved
  $("select[class='component-version-select'], select[class='provider-compute-resources']").livequery ->
    $(this).change ->
      renderNotSaved()
      calculateCosts()

  # prompt the user to save changes if they attempt to navigate away with un-saved changes
  $(window).bind "beforeunload", ->
    if window.location.pathname.match(/^(\/build|.*\/edit)$/)
      if $("#manifest-save-state").hasClass("btn-danger") and $("#dc-build-form").find(".assigned-component").size() > 0
        "You have unsaved changes - are you sure you wish to navigate away?"
  calculateCosts()

# handle turbolinks rails 4 document ready
$(document).ready(buildReady)
$(document).on('page:load', buildReady)

# change the saved state to "not saved"
@renderNotSaved = ->
  $("#manifest-save-state").html "<span class='glyphicon glyphicon-info-sign'></span> Not Saved"
  $("#manifest-save-state").removeClass("btn-success").addClass("btn-danger")

# calculate and display the hourly and monthly costs per category
# as well as the total overall provider costs per month/year
@calculateCosts = ->
  totalHourlyCost = 0.0

  $.each $(".category-hourly-cost"), (index, heading) ->
    hourlyCost = 0.0
    category   = $(heading).attr("id").replace("-category-hourly-cost", "")

    $.each $("#" + category + "-container").find(".assigned-component"), (index, component) ->
      $.each $(component).find("select.provider-compute-resources option:selected"), (index, option) ->
        hourlyCost += parseFloat($(option).attr("cost"))

    totalHourlyCost += hourlyCost
    $(heading).html "$ " + Number(hourlyCost).toFixed(3) + " /hr"
    $("#" + category + "-category-monthly-cost").html "$ " + Number(hourlyCost * 24.0 * 30.0).toFixed(3) + " /mo"

  totalMonthlyCost = Number(totalHourlyCost * 24.0 * 30.0).toFixed(2)
  totalYearlyCost  = Number(totalMonthlyCost * 12.0).toFixed(2)

  # update the visible costs
  $("#dc-cost-monthly-price").html "$" + totalMonthlyCost
  $("#dc-cost-yearly-price").html  "$" + totalYearlyCost

  # update the hidden input costs
  $("input#component_json_costs_hourly").val  Number(totalHourlyCost).toFixed(2)
  $("input#component_json_costs_monthly").val Number(totalMonthlyCost).toFixed(2)
  $("input#component_json_costs_yearly").val  Number(totalYearlyCost).toFixed(2)
