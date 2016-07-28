module Magnum
  module RouteSets
    class SuperProfile < Magnum::RouteSets::Base
      class << self
        def model
          Magnum::RouteSets::SuperProfileModel
        end
        def representer
          Magnum::RouteSets::SuperProfileRepresenter
        end

        def translate(json,options)
          model.new(options).extend(representer).from_json(json)
        end
      end
      register :super_profile
    end
  end
end

require 'magnum/route_sets/super_profile/representer'
require 'magnum/route_sets/super_profile/operations'
require 'magnum/route_sets/super_profile/services'
require 'magnum/route_sets/super_profile/conversion'
require 'magnum/route_sets/super_profile/tree'
require 'magnum/route_sets/super_profile/model'
