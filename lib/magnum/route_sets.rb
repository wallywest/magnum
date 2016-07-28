module Magnum
  module RouteSets

    module Registry
      def add(key,const = nil)
        if key.is_a?(Hash)
          key.each { |key, const| add(key, const) }
        else
          types[key.to_sym] = const
        end
      end

      def [](key)
        types[key.to_sym] || raise("can not use unregistered service #{key}. known types are: #{types.keys.inspect}")
      end

      def types
        @types ||= {}
      end
    end

    extend Registry

  end
end

require 'magnum/route_sets/util'
require 'magnum/route_sets/validation'
require 'magnum/route_sets/base'
require 'magnum/route_sets/week'
require 'magnum/route_sets/super_profile'
