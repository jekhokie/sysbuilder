require File.join(Rails.root, 'lib/view_handler.rb')
Dir[File.join(Rails.root, 'lib/provisioners/*.rb')].each{ |file| require file }

module VirtualEnv
  class Builder
    attr_accessor :view_handler

    def initialize(build_instance)
      @build_instance = build_instance
      @view_handler   = ViewHandler.new(build_instance.channel)
      @instance_ids   = []
      @dom_ids        = []
    end

    def create_environment
      # artificial hold to ensure the client-side JS can initialize
      sleep 3
      provision_threads = []
      percent_complete  = 25

      # set the build as in-progress
      @build_instance.update active: true

      # gather a list of the instance elements
      JSON.parse(@build_instance.configuration)["manifest"].each do |category, category_attrs|
        category_attrs.each do |instance_number, instance_attrs|
          dom_id = "#{category.gsub(/\s/, '_')}-#{instance_number.gsub(/\s/, '_')}-#{instance_attrs["name"].gsub(/\s/, '_')}"

          @dom_ids << dom_id

          return_js = ViewHandler.build_percentage_js(dom_id, "ID Provider...", percent_complete)
          @view_handler.publish return_js
        end
      end

      begin
        # Step 1: obtain a provisioner based on the vplatform
        @provisioner = case @build_instance.vplatform
                       when "Amazon EC2" then Provisioner::VagrantAws.new
                       when "Vagrant"    then Provisioner::VagrantVbox.new
                       else
                         raise "Unsupported provisioner type: #{@build_instance.vplatform}"
                       end

        # TODO: REMOVE
        sleep rand(3)

        # Step 2: create the manifest
        percent_complete = 50
        progress_all_components("Create Manifest...", percent_complete)

        @provisioner.create_manifest(@build_instance)
        percent_complete = 75

        # TODO: REMOVE
        sleep rand(3)

        # TODO: Create shared variable for all threads "build_success = true"
        # and have any thread update to false if any of the instances fail

        # spawn a build and status thread for each instance provision
        @dom_ids.each do |dom_id|
          provision_threads << Thread.new do
            view_handler = ViewHandler.new(@build_instance.channel)

            # Step 3: launch instance
            return_js = ViewHandler.build_percentage_js(dom_id, "Launch...", 75)
            view_handler.publish return_js

            # TODO: Launch instance

            # TODO: REMOVE
            sleep rand(5)

            return_js  = ViewHandler.build_percentage_js(dom_id, "Complete!", 100)
            return_js += ViewHandler.instance_complete_js(dom_id)
            view_handler.publish return_js
          end
        end

        provision_threads.each do |thread|
          thread.join
        end

        # complete and update view for launch button
        return_js = ViewHandler.full_complete_js(@build_instance.channel)
        @view_handler.publish return_js
      rescue Exception => e
        error_all_components("Error...", percent_complete)
        raise e
      ensure
        # terminate the build progress status
        @build_instance.update active: false
      end
    end

    private

    # move all instance progress bars to the same success state
    def progress_all_components(progress_message, percent_complete)
      js = ""

      @dom_ids.each do |dom_id|
        js += ViewHandler.build_percentage_js(dom_id, progress_message, percent_complete)
      end

      @view_handler.publish js
    end

    # move all instance progress bars to the same error state
    def error_all_components(error_message, percent_complete)
      js = ""

      @dom_ids.each do |dom_id|
        js += ViewHandler.instance_error_js(dom_id)
        js += ViewHandler.build_percentage_js(dom_id, error_message, percent_complete)
      end

      @view_handler.publish js
    end
  end

  # Module

  def self.new(build_instance)
    builder = Builder.new build_instance

    begin
      builder.create_environment
    rescue Exception => e
      builder.view_handler.publish ViewHandler.full_error_js
      Rails.logger.error "Received error while provisioning environment:\n#{e.message}"
    end
  end
end
