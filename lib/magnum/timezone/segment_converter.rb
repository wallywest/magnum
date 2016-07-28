module Magnum
  module TimeZone
    class SegmentConverter

      attr_reader :days

      def initialize(segment)
        @id = segment.id
        @converted_segments = []
        @days = Magnum::TimeZone::Days.new(segment)
        @time_zone = segment.time_zone
      end

      def convert_timezone(to_timezone)
        offset = standard_offset(to_timezone)
        apply_offset(offset)
        @days.utc_ranges
      end

      def standard_offset(timezone)
        offset = (ActiveSupport::TimeZone.new(timezone).utc_offset/60) - (ActiveSupport::TimeZone.new(@time_zone).utc_offset/60)
        offset
      end

      def apply_offset(offset)
        @days.apply_offset(offset)
      end
    end
  end
end
