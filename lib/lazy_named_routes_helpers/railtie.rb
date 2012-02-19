# load monkey patches to rails routing code according to Rails version
# log a warning if the rails version is not supported

ActiveSupport.on_load(:action_controller) do
  case Rails.version
  when /^3\.0/
    require 'lazy_named_routes_helpers/routing_monkey_patches_rails_3_0'
  else
    Rails.logger.warn "Rails version not compatible with lazy routing helper generation"
  end
end

