module Magnum
  module RouteSets
    class Week < Magnum::RouteSets::Base
      class << self
        def model
          Magnum::RouteSets::WeekModel
        end

        def representer
          Magnum::RouteSets::WeekRepresenter
        end

        def translate(json,options={})
          model.new(options).extend(representer).from_json(json)
        end

        def convert(pkg)
          package = Magnum::PackageSerializer.new(pkg).as_json(root: :package)[:package]
          label = {:vlabel => package[:vlabel], :description => package[:vlabel_map_description], :vlabel_id => package[:vlabel_id]}
          params = {
            :app_id => pkg.app_id,
            :time_zone => pkg.time_zone,
            :label => label
          }
          model.fromPackage(params,package)
        end

      end
      register :week
    end
  end
end

require 'magnum/route_sets/week/operations'
require 'magnum/route_sets/week/services'
require 'magnum/route_sets/week/representer'
require 'magnum/route_sets/week/conversion'
require 'magnum/route_sets/week/tree'
require 'magnum/route_sets/week/model'
