# patches for Rails 3.0 to generate named route helpers lazily
# modified:   actionpack/lib/action_dispatch/routing/route_set.rb
# modified:   actionpack/lib/action_dispatch/assertions/routing.rb
# modified:   actionpack/lib/action_view/test_case.rb

require 'action_dispatch/routing/route_set'
module ActionDispatch
  module Routing
    class RouteSet
      class NamedRouteCollection

        # new method needed for test processing
        def helper_method?(method_name)
          return false unless method_name.to_s =~ /^(.+)\_(url|path)$/
          get($1) != nil
        end

        def clear!
          # puts "patched clear! (#{object_id})"
          @routes = {}
          @helpers = []

          @module ||= Module.new do
            instance_methods.each { |selector| remove_method(selector) }
          end

          # puts "installing method_missing handler for named routes"
          @module.module_eval <<-'end_code', __FILE__, __LINE__ + 1
            private
            def __named_routes__; Rails.application.routes.named_routes; end
            def method_missing(method_name, *args, &block)
              begin
                # puts "missing url helper method #{method_name}"
                super
              rescue NameError
                raise unless method_name.to_s =~ /^(.+)\_(url|path)$/
                # puts "redefining #{method_name}"
                name, kind = $1.to_sym, $2.to_sym
                raise "route not found: #{name}" unless route = __named_routes__[name]
                opts = {:only_path => (kind == :path)}
                hash = route.defaults.merge(:use_route => name).merge(opts)
                __named_routes__.__send__(:define_hash_access, route, name, kind, hash)
                __named_routes__.__send__(:define_url_helper, route, name, kind, hash)
                __send__(method_name, *args, &block)
              end
            end
          end_code
        end #clear!
        alias clear clear!

        def add(name, route)
          routes[name.to_sym] = route
          # define_named_route_methods(name, route)
        end
        alias []=   add

        $generated_code = File.open("/tmp/generated_routing_code.rb", "w") if ENV['RAILS_DEBUG_ROUTING_CODE'].to_i==1

        def add_generated_code(code, tag, file, line)
          if $generated_code
            # $generated_code.puts "# route: #{@requirements.inspect}"
            $generated_code.puts code
            $generated_code.puts
            $generated_code.flush
          end
          # We use module_eval to avoid leaks
          @module.module_eval code, "generated code/#{tag}/(#{file}:#{line})"
        end

        def define_hash_access(route, name, kind, options)
          selector = hash_access_name(name, kind)
          code = <<-END_EVAL
          def #{selector}(options = nil)
            options ? #{options.inspect}.merge(options) : #{options.inspect}
          end
          protected :#{selector}
          END_EVAL
          add_generated_code code, "hash_access", __FILE__, __LINE__
          helpers << selector
        end

        def define_url_helper(route, name, kind, options)
          selector = url_helper_name(name, kind)
          hash_access_method = hash_access_name(name, kind)
          code = <<-END_EVAL
          def #{selector}(*args)
            options = #{hash_access_method}(args.extract_options!)
            if args.any?
              options[:_positional_args] = args
              options[:_positional_keys] = #{route.segment_keys.inspect}
            end
            url_for(options)
          end
          END_EVAL
          add_generated_code code, "url_helper", __FILE__, __LINE__
          helpers << selector
        end
      end
    end
  end
end

if Rails.env.test?

  require 'action_dispatch/testing/assertions/routing'
  module ActionDispatch
    module Assertions
      module RoutingAssertions
        # ROUTES TODO: These assertions should really work in an integration context
        def method_missing(selector, *args, &block)
          if @controller && @routes && @routes.named_routes.helper_method?(selector)
            @controller.__send__(selector, *args, &block)
          else
            super
          end
        end
      end
    end
  end

  require 'action_view/test_case'
  module ActionView
    class TestCase
      def method_missing(selector, *args, &block)
        if @controller.respond_to?(:_routes) && @controller._routes.named_routes.helper_method?(selector)
          @controller.__send__(selector, *args, &block)
        else
          super
        end
      end
    end
  end
end
