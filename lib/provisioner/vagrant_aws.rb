class Provisioner::VagrantAws < Provisioner
  @@manifest          = File.join(Rails.root, 'lib/templates/aws_vagrantfile.erb')
  @@aws_configuration = YAML::load(File.open(File.join(Rails.root, 'config/aws_configs.yml')))[:aws]

  def initialize
    super
  end

  def create_manifest(build_instance)
    @provider_settings = @@provider_settings[:"Amazon EC2"]
    @erb_template      = ERB.new(File.read(@@manifest))
    @aws_configuration = @@aws_configuration
    super
  end
end
