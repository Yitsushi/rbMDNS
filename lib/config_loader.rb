require 'rubygems'
require 'yaml'

module ConfigLoader
  def load_config
    @config = YAML.load_file('config.yml')
  end
end
