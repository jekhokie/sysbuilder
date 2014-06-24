exploreReady = ->
  # allow the user to select and navigate clicking anywhere on the manifest row
  $("#manifest-listing table tbody tr").livequery ->
    $(this).click ->
      window.location.href = $(this).find("td.manifest-name a").attr("href")

# handle turbolinks rails 4 document ready
$(document).ready(exploreReady)
$(document).on('page:load', exploreReady)
