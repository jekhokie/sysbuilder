buildLaunch = ->
  # handle the user requesting the manifest be provisioned as a data center
  $("button#launch-dc").livequery ->
    $(this).click ->
      # disable the launch button to prevent inadvertant subsequent launches
      $(this).attr "disabled", "disabled"

      # submit notice to the server that the launch is to be started
      $.ajax $("input#provision-path").val(),
        context: this
        type:    "POST"
        success: (obj) ->
          eval obj
          return

# handle turbolinks rails 4 document ready
$(document).ready(buildLaunch)
$(document).on('page:load', buildLaunch)
