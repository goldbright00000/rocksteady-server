require "yaml"

module Rocksteady
  config_path = File.expand_path(File.join(File.dirname(__FILE__), '../'))

  # preload const values from config
  config              = {}

  if File.exist?(config_file = File.join(config_path, 'config.yml'))
    config = YAML.load(File.read(config_file))
  end

  SHIPPING_MINIMAL_VALUE      = config.empty? ? 20 : config['shipping_minimal_price']
  DISCOUNT_TYPE_NONE          = config.empty? ? 'none' : config['discount_type']['none']
  DISCOUNT_TYPE_PROMOTION     = config.empty? ? 'promotion' : config['discount_type']['promotion']
  DISCOUNT_TYPE_ORDER_FIX     = config.empty? ? 'order fix' : config['discount_type']['order_fix']
  DISCOUNT_TYPE_CHANGE_DESIGN = config.empty? ? 'change design' : config['discount_type']['change_design']
end
