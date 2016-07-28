require 'set'

module Magnum
  module RouteSets
    module WeekOperations
      def create_segment(params)
        add_segment(params.first)
      end

      def modify_segment(params)
        old = params.first
        original = old.clone
        new = squash(params[1].build_utc_segments)
        range = new.keys.first
        old.start_time = range.first
        old.end_time = range.last
        old.dirty = true
        old.build_utc_segments
        old.dirty_ids = dirty_routes(original)
      end

      def delete_segment(params)
        remove_segment(params.first)
      end

      def dirty_routes(original)
        range = squash(original.build_utc_segments)
        ds = $DB[:yacc_route].filter(
          :route_name => self.labels.map(&:vlabel),
          :day_of_week => range.values,
          :begin_time => range.keys.first.first,
          :end_time => range.keys.first.last,
          :app_id => self.app_id
        ).select(:route_id).all.map{|x| x[:route_id]}
        ds
      end

      def add_segment(segment)
        segment.time_zone = self.time_zone
        self.segments << segment unless self.segments.include?(segment)
        tree.add_segment(segment)
      end

      def remove_segment(segment)
        self.segments.delete_if{|s| s.id == segment.id}
        tree.remove_segment(segment)
      end

      def add_allocation(segment,allocation)
        self.allocations << allocation unless self.allocations.include?(allocation)
        tree.add_allocation(segment,allocation)
      end

      def add_multiple_allocations(segment,allocations)
        allocations.each do |allocation|
          add_allocation(segment,label,allocation)
        end
      end

      def remove_allocation(segment,allocation)
        tree.remove_allocation(segment,allocation)
        self.allocations.reject!{|a| a.id == allocation.id}
      end
    end
  end
end
