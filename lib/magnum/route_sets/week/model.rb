module Magnum
  module RouteSets
    class WeekModel

      def self.fromPackage(params,package)
        model = new(params)
        model.convert(package)
        model
      end

      include Magnum::Util

      include WeekServices
      include WeekOperations
      include WeekValidation
      include WeekConversions

      include Virtus.model

      attribute :label, Magnum::Label
      attribute :id, Integer
      attribute :name, String
      attribute :description, String
      attribute :app_id, Integer
      attribute :segments, Array
      attribute :allocations, Array
      attribute :time_zone, String, :default => "UTC"
      attribute :tree, Magnum::WeekProfileTree, :default => :default_tree

      def build_routes
        routes = []
        self.segments.each do |segment|
          segment.time_zone = self.time_zone
          convert_to_route(segment) {|r| routes.push(r)}
        end
        routes
      end

      def default_tree
        WeekProfileTree.new
      end

      def has_dequeue?
        company = ::Company.find(self.app_id)
        dqs = self.allocations.map(&:dequeues).flatten
        !dqs.empty? && company.queuing_active?
      end

      private
      def convert_to_route(segment)
        segment.build_utc_segments
        route_pairings = squash(segment.utc_segments)
        node = tree.find_segment_node(segment.id)
        route_pairings.each do |range,days|
          data_allocations = find_allocation(node)
          yield Magnum::Route.new(self.app_id,self.label.vlabel,days,range.first,range.last,data_allocations)
        end
      end

    end
  end
end
