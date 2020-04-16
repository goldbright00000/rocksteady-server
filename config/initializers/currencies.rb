require 'yaml'

override_path = Rails.root.join('config/currency_override.yml')

if File.exist? override_path
  OVERRIDE_VALUES = YAML.load(File.read(override_path))
else
  OVERRIDE_VALUES = {}
end
