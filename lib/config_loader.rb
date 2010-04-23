require 'rubygems'
require 'yaml'

=begin rdoc
  ConfigLoader
  ---
  Load the YAML based configuration file
=end
module ConfigLoader
  def load_config
    @config = YAML.load_file('config.yml')
  end
end
