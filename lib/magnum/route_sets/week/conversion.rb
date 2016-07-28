module Magnum
  module RouteSets
    module WeekConversions
      def convert(package)
        can_create_segments = true if self.segments.empty?
        package[:profiles].each do |profile|
          days = profile[:dayString]
          profile[:time_segments].each do |segment|
            seg = Set.new [days, segment[:start_min],segment[:end_min]]
            msegment = self.findOrCreateSegment(seg,can_create_segments)
            segment[:routings].each do |routing|
              percentage = "#{routing[:percentage]}"
              destinations = routing[:routing_exits].map{|x| x.except(:id,:call_priority)}
              a = Set.new [percentage,destinations]
              allocation = self.newAllocation(a)
              self.add_allocation(msegment,allocation)
            end
          end
        end
      end
    end
  end
end
