module Magnum
  module TimeZone
    class RangeCollection
      attr_reader :segments, :binaries, :set
      def initialize(ranges,set)
        @groupings = []
        @set = set
        @binaries = Set.new
        ranges.each do |binary,mapping|
          grouping = RangeGroup.new(binary,mapping)
          grouping.reduce
          @groupings << grouping
        end
        squash
      end

      def squash
        @segments = []
        @groupings.group_by(&:ranges).each do |ranges,grouping|
          ranges.each do |range|
            binary = 0
            grouping.each {|group| binary = binary | group.binary}
            s = [binary,range.min,range.max]
            @binaries << binary
            @segments << s
          end
        end
      end

      def splitBinary(value,parts)
        segs = segments.select{|x| x[0] == value}
        segments.delete_if {|x| x[0] == value}

        segs.each do |seg|
          parts.each do |binary|
            segments << [binary,seg[1],seg[2]]
          end
        end

        s = Set.new
        s.merge(parts)
        @binaries = s
      end

    end

    class RangeGroup
      attr_reader :ranges,:binary

      def initialize(binary,mapping)
        @binary = binary
        @unmerged = []
        mapping.each do |segment|
          range = (segment.start..segment.end)
          @unmerged << range
          @unmerged.sort_by!{|x| x.min}
        end
        reduce
      end

      def reduce
        @ranges = @unmerged.rangify
      end
    end

  end
end
