buildLaunch = ->
  # handle the user requesting the manifest be provisioned as a data center
  $("button#launch-dc").livequery ->
    $(this).click ->
      # disable the launch button and indicate in-progress to prevent inadvertant subsequent launches
      $(this).attr "disabled", "disabled"
      $(this).addClass "active"
      $(this).find(".progress-spinner").spin
        lines:  8
        width:  3
        length: 3
        radius: 3
        speed:  1.5
        top:    '-13px'
        left:   '-22px'

      # submit notice to the server that the launch is to be started
      $.ajax $("input#provision-path").val(),
        type:    "POST"
        success: (obj) ->
          # evaluate the response, including establishing the progress bars
          eval obj

          # assign the custom channel on which the response/channel updates will occur
          window.fayeClient.subscribe $("input#build-status-channel").val(), (payload) ->
            eval payload

          return


# handle turbolinks rails 4 document ready
$(document).ready(buildLaunch)
$(document).on('page:load', buildLaunch)
