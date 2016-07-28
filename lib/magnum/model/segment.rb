module Magnum
  class Segment < OpenStruct
    DAYS = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]

    def value
      @value ||= Set.new [self.days,self.start_time,self.end_time]
    end

    def build_utc_segments
      utc_segments = Magnum::TimeZone::SegmentConverter.new(self).convert_timezone("UTC")
      self.utc_segments = flatten(utc_segments)
    end

    def translate_segment(time_zone)
      converted_segments = Magnum::TimeZone::SegmentConverter.new(self).convert_timezone(time_zone)
      segs = flatten(converted_segments)
      self.translated_segments = segs
    end

    def flatten(segments)
      segments.each_pair do |binary,values|
        next if values.size <= 1
        merge(values)
      end
      segments
    end

    def merge(values)
      pairs = values.map{|x| [x.start,x.end]}.sort
      m = pairs.shift
      pairs.each do |pair|
        last = m.last
        if (last + 1) == pair.first
          m[1] = pair.last
          values.delete_if{|x| x.start == pair.first}
          values.select{|x| x.start == m[0]}.first.end = m[1]
        end
      end
    end

    def equal(set)
      return set == self.value
    end

    def splitDays
      {
       :sun => self.days[0],
       :mon => self.days[1],
       :tue => self.days[2],
       :wed => self.days[3],
       :thu => self.days[4],
       :fri => self.days[5],
       :sat => self.days[6]
      }
    end
  end

end
