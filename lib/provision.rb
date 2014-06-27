require 'net/http'

module Provision
  class Builder
    def provision(build_instance)
      # artificial delay to allow client-side JavaScript to set up Faye subscription before
      # starting to provision and send messages (otherwise, first step is almost always missed)
      sleep 3

      # set the build as in-progress
      build_instance.update active: true

      # initialize faye settings
      faye_settings = YAML::load(File.open(File.join(Rails.root, 'config/faye.yml')))
      message       = { :channel => build_instance.channel, :data => "", :ext => { :auth_token => FAYE_TOKEN } }
      uri           = URI.parse("#{faye_settings["protocol"]}://#{faye_settings["host"]}:#{faye_settings["port"]}/faye")

      # set up for provisioning
      provision_threads = []
      instance_ids      = []
      build_success     = true
      build_config      = JSON.parse(build_instance.manifest.configuration)
      hosts             = build_config["manifest"]
      provider          = build_config["provider"]

      # gather a list of the instance elements
      hosts.each do |category, category_attrs|
        category_attrs.each do |instance_number, instance_attrs|
          element_id    = "#{category.gsub(/\s/, '_')}-#{instance_number.gsub(/\s/, '_')}-#{instance_attrs["name"].gsub(/\s/, '_')}"
          instance_ids << element_id

          # initialize the first phase of each progress bar
          message[:data] = update_progress_javascript(element_id, "Create Manifest...", 33)
          Net::HTTP.post_form(uri, :message => message.to_json)
        end
      end

      # step 1: create the Vagrant file
      unless create_manifest(build_instance)
        message[:data] = ""

        instance_ids.each do |element_id|
          message[:data] += show_instance_error_javascript(element_id, build_instance.channel)
          message[:data] += update_progress_javascript(element_id, "Error...", 33)
        end

        message[:data] += show_full_error_javascript
        Net::HTTP.post_form(uri, :message => message.to_json)

        return 1
      end

      # spawn a build and status thread for each instance provision
      instance_ids.each do |element_id|
        provision_threads << Thread.new do
          thread_message = { :channel => build_instance.channel, :data => "", :ext => { :auth_token => FAYE_TOKEN } }

          # step 2: launch the instance
          thread_message[:data] = update_progress_javascript(element_id, "Launch...", 66)
          Net::HTTP.post_form(uri, :message => thread_message.to_json)

          # TODO: IMPLEMENT LAUNCH OF AWS INSTANCE
          unless true
            build_success = false

            thread_message[:data]  = show_instance_error_javascript(element_id, build_instance.channel)
            thread_message[:data] += update_progress_javascript(element_id, "Error...", 66)
            Net::HTTP.post_form(uri, :message => thread_message.to_json)

            Thread.exit
          end
          sleep rand(5)

          # step 3: report complete
          complete_message       = update_progress_javascript(element_id, "Complete!", 100)
          complete_message      += show_instance_complete_javascript(element_id)
          thread_message[:data]  = complete_message
          Net::HTTP.post_form(uri, :message => thread_message.to_json)
        end
      end

      provision_threads.each do |thread|
        thread.join
      end

      # set the build as complete
      build_instance.update active: false

      # handle events for completed data center provision
      if build_success
        message[:data] = show_full_complete_javascript(build_instance.channel)
      else
        message[:data] = show_full_error_javascript
      end

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

    # display an error for the corresponding build component and update the screen appropriately
    def show_instance_error_javascript(element_id, channel)
      error_js  = "$('##{element_id}-progress').removeClass('active').removeClass('progress-striped');"
      error_js += "$('##{element_id}-progress .progress-bar').removeClass('progress-bar-info').addClass('progress-bar-danger');"
      error_js
    end

    # update any progress spinners and unsubscribe from faye channel
    def show_full_complete_javascript(channel)
      complete_js  = "$('#launch-dc .progress-spinner').spin(false);"
      complete_js += "$('#launch-dc').removeClass('btn-info').addClass('btn-success');"
      complete_js += "$('#launch-dc').html('<span class=\"glyphicon glyphicon-ok\"></span> Complete!');"
      complete_js += "window.fayeClient.unsubscribe('#{channel}');"
      complete_js
    end

    # display an error for all build components and update the screen appropriately
    def show_full_error_javascript
      error_js  = "$('#launch-dc .progress-spinner').spin(false);"
      error_js += "$('#launch-dc').removeClass('btn-info').addClass('btn-danger');"
      error_js += "$('#launch-dc').html('<span class=\"glyphicon glyphicon-remove\"></span> Error!');"
      error_js
    end

    # create the required vagrant file based on the provider
    def create_manifest(build)
      host_list     = {}
      num_instances = 0
      id_tag        = "#{build.id}-ABC"

      # build the hash for constructing the Vagrant file
      JSON.parse(build.configuration)["manifest"].each do |category, category_attrs|
        category_attrs.each do |instance, instance_attrs|
          instance_id               = "#{build.id}-#{category.gsub(' ', '_')}-#{instance.to_s}-#{instance_attrs["name"].gsub(' ', '_')}"
          host_list[num_instances]  = { "instance_id" => instance_id }
          num_instances            += 1
        end
      end

      # determine parameters based on the platform/provider
      if build.vplatform == "Amazon EC2"
        aws_settings = YAML::load(File.open(File.join(Rails.root, 'config/aws_configs.yml')))[:aws]
        vagrant_file = File.join(Rails.root, 'lib/templates/aws_vagrantfile.erb')
      elsif build.vplatform == "Vagrant"
      else
        return false
      end

      # construct the build directory
      build_dir = "tmp/builds/#{build.id}"
      Dir.mkdir(build_dir, 0750) unless Dir.exists?(build_dir)

      # construct the Vagrantfile
      erb_template = ERB.new(File.read(vagrant_file))
      File.open(File.join(Rails.root, build_dir, "Vagrantfile"), "w") { |f| f.write erb_template.result(binding) }

      return true
    end
  end

  # provision a data center based on a manifest
  def self.start(build_instance)
    builder = Builder.new
    builder.provision(build_instance)
  end
end
