require 'net/http'

module Provision
  class Builder
    def provision(build_instance)
      # set the build as in-progress
      build_instance.update active: true

      # initialize faye settings
      faye_settings = YAML::load(File.open(File.join(Rails.root, 'config/faye.yml')))
      message       = { :channel => build_instance.channel, :data => "", :ext => { :auth_token => FAYE_TOKEN } }
      uri           = URI.parse("#{faye_settings["protocol"]}://#{faye_settings["host"]}:#{faye_settings["port"]}/faye")

      # set up for provisioning
      provision_threads = []
      build_config      = JSON.parse(build_instance.manifest.configuration)
      hosts             = build_config["manifest"]
      provider          = build_config["provider"]

      # spawn a build and status thread for each instance
      hosts.each do |category, category_attrs|
        category_attrs.each do |instance_number, instance_attrs|
          provision_threads << Thread.new do
            element_id = "#{category.gsub(/\s/, '_')}-#{instance_number.gsub(/\s/, '_')}-#{instance_attrs["name"].gsub(/\s/, '_')}"

            # step 1: create the Vagrant file
            message[:data] = update_progress_javascript(element_id, "Create Manifest...", 25)
            Net::HTTP.post_form(uri, :message => message.to_json)
            sleep rand(5)

            # step 2: launch the instance
            message[:data] = update_progress_javascript(element_id, "Launch...", 50)
            Net::HTTP.post_form(uri, :message => message.to_json)
            sleep rand(5)

            # step 3: provision the instance with Puppet
            message[:data] = update_progress_javascript(element_id, "Provision...", 75)
            Net::HTTP.post_form(uri, :message => message.to_json)
            sleep rand(5)

            # step 4: report complete
            complete_message  = update_progress_javascript(element_id, "Complete!", 100)
            complete_message += show_instance_complete_javascript(element_id)
            message[:data]    = complete_message
            Net::HTTP.post_form(uri, :message => message.to_json)
          end
        end
      end

      provision_threads.each do |thread|
        thread.join
      end

      # set the build as complete
      build_instance.update active: false

      # handle events for completed data center provision
      message[:data] = show_full_complete_javascript(build_instance.channel)
      Net::HTTP.post_form(uri, :message => message.to_json)

      return
    end

    private

    # update the progress bars for build status
    def update_progress_javascript(element_id, status, percent_complete)
      update_js = "$('##{element_id}-progress .progress-bar').css('width', '#{percent_complete}%').html('#{status} (#{percent_complete}%)');"
      update_js
    end

    # change progress bar to 100% complete style when component is provisioned
    def show_instance_complete_javascript(element_id)
      complete_js  = "$('##{element_id}-progress').removeClass('active').removeClass('progress-striped');"
      complete_js += "$('##{element_id}-progress .progress-bar').removeClass('progress-bar-info').addClass('progress-bar-success');"
      complete_js
    end

    # update any progress spinners and unsubscribe from faye channel
    def show_full_complete_javascript(channel)
      complete_js  = "$('#launch-dc .progress-spinner').spin(false);"
      complete_js += "$('#launch-dc').removeClass('btn-info').addClass('btn-success');"
      complete_js += "$('#launch-dc').html('<span class=\"glyphicon glyphicon-ok\"></span> Complete!');"
      complete_js += "window.fayeClient.unsubscribe('#{channel}');"
      complete_js
    end
  end

  # provision a data center based on a manifest
  def self.start(build_instance)
    builder = Builder.new
    builder.provision(build_instance)
  end
end
