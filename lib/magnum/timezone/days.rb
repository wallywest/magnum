require 'segment_tree'
module Magnum
  module TimeZone
    class Days

      MAX_MINUTES = 10080
      Day = Struct.new(:binary,:floor,:ceiling,:name)
      UTCSegment = Struct.new(:start,:end,:segment_id)
      
      attr_reader :selected_days, :ranges, :utc_ranges

      SUN = Day.new(0b1000000,0,1439,"sunday")
      MON = Day.new(0b0100000,1440,2879,"monday")
      TUE = Day.new(0b0010000,2880,4319,"tuesday")
      WED = Day.new(0b0001000,4320,5759,"wednesday")
      THU = Day.new(0b0000100,5760,7199,"thursday")
      FRI = Day.new(0b0000010,7200,8639,"friday")
      SAT = Day.new(0b0000001,8640,10079,"saturday")

      WEEK = [SUN,MON,TUE,WED,THU,FRI,SAT]
      TREE_RANGE = {
        0..1439 => SUN,
        1440..2879 => MON,
        2880..4319 => TUE,
        4320..5759 => WED,
        5760..7199 => THU,
        7200..8639 => FRI,
        8640..10079 => SAT
      }

      def initialize(segment)
        @id = segment.id
        @utc_ranges = {
          64 => [],
          32 => [],
          16 => [],
          8 => [],
          4 => [],
          2 => [],
          1 => []
        }
        @ranges = []
        @segment_tree = SegmentTree.new(TREE_RANGE)
        @minute_range = (segment.start_time.to_i..segment.end_time.to_i)
        @selected_days = WEEK.select do |day|
          value = segment.days.to_i(2) & day.binary
          value != 0
        end
        minutes_from_range
      end

      def minutes_from_range
        @selected_days.each do |day|
          s = day.floor + @minute_range.first
          e = s + (@minute_range.to_a.length - 1)
          @ranges << UTCSegment.new(s,e,@id)
        end
      end

      def apply_offset(offset)
        @ranges.each do |range|
          _offset_range = range.dup
          _offset_range.start += offset
          _offset_range.end += offset
          split_merge_range(_offset_range,offset)
        end
      end

      def split_merge_range(range,offset)
        _temp = range.dup
        _start = normalize_value(_temp.start) % MAX_MINUTES
        _end = normalize_value(_temp.end) % MAX_MINUTES
        floor = @segment_tree.find(_start).value
        ceiling = @segment_tree.find(_end).value

        if offset < 0
          negative_offset(_temp,_start,_end,floor,ceiling)
        else
          positive_offset(_temp,_start,_end,floor,ceiling)
        end
      end

      def positive_offset(range,_start,_end,floor,ceiling)
        if floor.binary > ceiling.binary
          range.end = floor.ceiling
          new_range = UTCSegment.new(ceiling.floor,_end,@id)
          add_and_merge(range)
          add_and_merge(new_range)
        elsif floor.binary < ceiling.binary
          range.end = floor.ceiling
          new_range = UTCSegment.new(ceiling.floor,_end,@id)
          add_and_merge(range)
          add_and_merge(new_range)
        else
          range.start = _start
          range.end = _end
          add_and_merge(range)
        end
      end

      def negative_offset(range,_start,_end,floor,ceiling)
        if floor.binary > ceiling.binary
          range.end = floor.ceiling
          new_range = UTCSegment.new(ceiling.floor,_end,@id)
          add_and_merge(range)
          add_and_merge(new_range)
        elsif floor.binary < ceiling.binary
          range.start = ceiling.floor
          new_range = UTCSegment.new(_start,floor.ceiling,@id)
          add_and_merge(range)
          add_and_merge(new_range)
        else
          range.start = _start
          range.end = _end
          add_and_merge(range)
        end
      end

      def add_and_merge(range)
        binary = @segment_tree.find(range.start).value.binary
        ranges = @utc_ranges[binary]
        range.start = range.start % 1440
        range.end = range.end % 1440
        ranges.push(range)
      end

      def normalize_value(value)
        if value < 0
          value = MAX_MINUTES - (value.abs)
        end
        value
      end

    end
  end
end
