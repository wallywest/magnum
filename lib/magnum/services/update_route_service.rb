module Magnum
  module Service
    class UpdateRoute
      #this is only used by a super profile currently

      def initialize(rs,params)
        @rs = rs
        @options = params
        build_routes
      end

      def run
        persistence = Magnum::RoutePersistence.new(routes,filter)
        persistence.save
      end

      def filter
        @filter
      end

      def routes
        @routes ||= []
      end

      private

      def vlabels
        @vlabels ||= []
      end

      def labels
        options[:labels] ||= []
      end

      def segment
        @segment ||= Magnum::Segment.new(options[:segment].merge!(:time_zone => rs.time_zone))
      end

      def options
        @options
      end

      def rs
        @rs
      end

      def build_routes
        labels.each do |raw_label|
          label = Magnum::Label.new(raw_label)
          rs.update_allocations(allocations_for(raw_label),segment,label)

          vlabels << label.vlabel

          rs.segments.each do |segment|
            segment.time_zone = rs.time_zone
            rs.build_segment(segment) do |route|
              routes << route if route[:route_name] == label.vlabel
            end
          end
        end

        filter_params = {route_name: vlabels, app_id: rs.app_id}
        @filter = Magnum::Filter::treeFilter(filter_params)
      end

      def allocations_for(label)
        label[:allocations].map do |allocation|
          Magnum::Allocation.new.extend(Magnum::AllocationRepresenter).from_json(allocation.except(:item).to_json)
        end
      end
    end
  end
end

