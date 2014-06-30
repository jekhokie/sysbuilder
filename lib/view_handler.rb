require 'net/http'

# class to handle the view update aspects of any dynamic updates
class ViewHandler
  @@status_settings = YAML::load(File.open(File.join(Rails.root, 'config/faye.yml')))
  @@status_uri      = URI.parse("#{@@status_settings["protocol"]}://#{@@status_settings["host"]}:#{@@status_settings["port"]}/faye")

  def initialize(pub_channel)
    @status_message = { :channel => pub_channel, :data => "", :ext => { :auth_token => FAYE_TOKEN } }
  end

  def publish(message)
    @status_message[:data] = message
    Net::HTTP.post_form(@@status_uri, :message => @status_message.to_json)
  end

  #################################################
  # JavaScript builder/helper methods
  #
  # update the progress bars for build status
  def self.build_percentage_js(element_id, status, percent_complete)
    js = "$('##{element_id}-progress .progress-bar').css('width', '#{percent_complete}%').html('#{status} (#{percent_complete}%)');"
    js
  end

  # display an error for the corresponding build component and update the screen appropriately
  def self.instance_error_js(element_id)
    js  = "$('##{element_id}-progress').removeClass('active').removeClass('progress-striped');"
    js += "$('##{element_id}-progress .progress-bar').removeClass('progress-bar-info').addClass('progress-bar-danger');"
    js
  end

  # display an error for all build components and update the screen appropriately
  def self.full_error_js
    js  = "$('#launch-dc .progress-spinner').spin(false);"
    js += "$('#launch-dc').removeClass('btn-info').addClass('btn-danger');"
    js += "$('#launch-dc').html('<span class=\"glyphicon glyphicon-remove\"></span> Error!');"
    js
  end

  # update any progress spinners and unsubscribe from faye channel
  def self.full_complete_js(channel)
    js  = "$('#launch-dc .progress-spinner').spin(false);"
    js += "$('#launch-dc').removeClass('btn-info').addClass('btn-success');"
    js += "$('#launch-dc').html('<span class=\"glyphicon glyphicon-ok\"></span> Complete!');"
    js += "window.fayeClient.unsubscribe('#{channel}');"
    js
  end

  # change progress bar to 100% complete style when component is provisioned
  def self.instance_complete_js(element_id)
    js  = "$('##{element_id}-progress').removeClass('active').removeClass('progress-striped');"
    js += "$('##{element_id}-progress .progress-bar').removeClass('progress-bar-info').addClass('progress-bar-success');"
    js
  end
end
