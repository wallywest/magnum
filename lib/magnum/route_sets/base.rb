module Magnum
  module RouteSets
    class Base
      def self.register(key)
        Magnum::RouteSets.add(key,self)
      end
    end
  end
end
