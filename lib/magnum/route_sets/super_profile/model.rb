module Magnum
  module RouteSets
    class SuperProfileModel
      include Virtus.model

      include Magnum::Util

      include SuperProfileServices
      include SuperProfileOperations
      include SuperProfileValidations
      include SuperProfileConversion

      attribute :app_id, Integer
      attribute :status, String
      attribute :segments, Array
      attribute :allocations, Array
      attribute :labels, Array
      attribute :time_zone, String, :default => "UTC"
      attribute :tree, Magnum::SuperProfileTree, :default => :default_tree

      def default_tree
        SuperProfileTree.new
      end

      def empty?
        self.labels.blank? && self.segments.blank? && self.allocations.blank?
      end

      def emptyLabels?
        labs = self.labels.select{|x| !x.isDelete}
        labs.blank?
      end

      def has_dequeue?
        company = ::Company.find(self.app_id)
        dqs = self.allocations.map(&:dequeues).flatten
        !dqs.empty? && company.queuing_active?
      end

      def build_routes
        routes = []
        self.segments.each do |segment|
          segment.time_zone = self.time_zone
          self.build_segment(segment) do |route|
            routes << route
          end
        end
        routes
      end
    end
  end
end

