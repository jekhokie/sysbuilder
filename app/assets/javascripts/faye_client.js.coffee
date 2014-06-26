fayeClientLaunch = ->
  window.fayeClient = new Faye.Client('/faye')

# handle turbolinks rails 4 document ready
$(document).ready(fayeClientLaunch)
$(document).on('page:load', fayeClientLaunch)
