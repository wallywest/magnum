require 'set'

module Magnum
  module TimeZone
    class Converter
      attr_reader :grouped_segments

      def initialize(object,new_tz)
        @object = object
        @segments = object.segments
        @old_tz = object.time_zone
        @new_tz = new_tz
        @collections = []
        @mapping = []
        @binaries = Set.new
        group_equal_segments
      end

      def group_equal_segments
        @segments.each_with_index do |segment,index|
          pointer = index + 1
          set = segment.equal_segs ||= Set.new
          set << segment.id
          current_id = segment.id
          @segments[pointer..@segments.length].each do |inner_seg|
            inner_set = inner_seg.equal_segs ||= Set.new
            current_id = segment.id
            if(@object.equalAllocation(current_id,inner_seg.id))
               set << inner_seg.id
               inner_set << current_id
            end
          end
        end
        @grouped_segments = @segments.group_by(&:equal_segs)
      end

      def translate_and_combine
        @grouped_segments.each do |set,segments|
          mapping = {64 => [], 32 => [], 16 => [], 8 => [], 4 => [], 2 => [], 1 => []}
          segments.each do |segment|
            segment.time_zone = @old_tz
            segment.translate_segment(@new_tz)
            segment.translated_segments.each_with_object(mapping).each{|(k,v),h| h[k] += v}
          end
          collection = Magnum::TimeZone::RangeCollection.new(mapping,set)
          @binaries.merge(collection.binaries)
          @collections << collection
        end
        verify_binaries
      end

      def verify_binaries
        binaries.to_a.combination(2).each do |value|
          val = value[0] & value[1]
          if val != 0
            overlap = value[0]
            split = [val,overlap ^ val]
            @collections.select{|c| c.binaries.include?(overlap)}.each do |collection|
              collection.splitBinary(overlap,split)
            end
          end
        end
      end

      def binaries
        @binaries.sort_by{|x| x}.reverse
      end
      def convert
        translate_and_combine
        @collections
      end
    end
  end
end
