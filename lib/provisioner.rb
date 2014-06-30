class Provisioner
  @@provider_settings = YAML::load(File.open(File.join(Rails.root, 'config/compute_providers.yml')))

  attr_accessor :host_list

  def initialize
  end

  def create_manifest(build_instance)
    begin
      @host_list    = {}
      num_instances = 0

      # construct the build directory
      build_dir = File.join(Rails.root, "tmp/builds/#{build_instance.id}")
      Dir.mkdir(build_dir, 0750) unless Dir.exists?(build_dir)

      # build the hash for constructing the Vagrant file
      JSON.parse(build_instance.configuration)["manifest"].each do |category, category_attrs|
        category_attrs.each do |instance, instance_attrs|
          safe_category = category.gsub(' ', '_')
          safe_name     = instance_attrs["name"].gsub(' ', '_')
          instance_id   = "#{build_instance.id}-#{safe_category}-#{instance.to_s}-#{safe_name}"

          @host_list[num_instances] = { "instance_id" => instance_id, "vresource" => instance_attrs["vresource"] }

          num_instances += 1
        end
      end

      # construct the Vagrantfile
      File.open(File.join(build_dir, "Vagrantfile"), "w") { |f| f.write @erb_template.result(binding) }
    rescue Exception => e
      raise "Error building the provisioning manifest: #{e.message}"
    end
  end
end
