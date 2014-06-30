class Provisioner::VagrantVbox < Provisioner
  @@manifest = File.join(Rails.root, 'lib/templates/virtualbox_vagrantfile.erb')

  def initialize
    super
  end

  def create_manifest(build_instance)
    @provider_settings = @@provider_settings[:"Vagrant"]
    @erb_template      = ERB.new(File.read(@@manifest))
    super
  end
end
