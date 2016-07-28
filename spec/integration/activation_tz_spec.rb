require 'spec_helper'

describe "UTC Conversion Coverage", :type => :integration do
  before(:each) do
    Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
  end

  MagnumTest.getValidTimeZoneSuperProfiles.each do | profile |
    puts profile["name"]
    profile.delete("_id")
    sp = Magnum::build(:super_profile, profile.to_json)

    describe "time zone logic for #{profile['name']}" do
      it "should convert time segments into UTC" do
        sp_as_utc = Magnum::build(:super_profile, profile.to_json)
        sp_as_utc.convertTimeZone('UTC')

        before_conversion_segments = sp.segments
        after_conversion_segments  = sp_as_utc.segments

        offset = (ActiveSupport::TimeZone.new(sp.time_zone).utc_offset - ActiveSupport::TimeZone.new('UTC').utc_offset)/60

        before_conversion_segments.each do | segment |
          result = segment_covered?(segment, after_conversion_segments, sp, sp_as_utc)
          expect(result).to eq(true)
        end
      end

      def segment_covered?(segment, utc_segments, superprofile, utc_superprofile)
        time_considerate_segments = convert_time_zone(segment, superprofile)
        time_considerate_segments.each do | seg |
          utc_segments_with_similar_days = days_covered(seg, utc_segments)

          if(utc_segments_with_similar_days.size >= 1)
            if(time_range_covered?(seg, utc_segments_with_similar_days))
              if(allocation_covered?(seg, superprofile, utc_superprofile))
                return true

              end
            end
          end
        end
        return false
      end

      def days_covered(seg, utc_segments)
        days = seg.days.to_i(2)
        segments = []
        utc_segments.each do | utc_seg |
          utc_days = utc_seg.days.to_i(2)
          if(days & utc_days != 0)
            segments << utc_seg
          end
        end
        return segments
      end

      def convert_time_zone(segment, sp)
        offset = (ActiveSupport::TimeZone.new(sp.time_zone).utc_offset - ActiveSupport::TimeZone.new('UTC').utc_offset)/60
        possibly_multiple_segment = []
        start_time = segment.start_time.to_i - offset
        end_time = segment.end_time.to_i - offset
        if(start_time > 1439 && end_time > 1439)
          new_start_time = start_time % 1439
          new_end_time = end_time % 1439 - 1
          possibly_multiple_segment << Magnum::Segment.new( :id => segment.id, :start_time => new_start_time, :end_time => new_end_time, :days => next_day(segment.days))
        end

        if(start_time < 1439 && end_time > 1439)
          new_end_time = end_time % 1439 - 1
          possibly_multiple_segment << Magnum::Segment.new( :id => segment.id, :start_time => start_time, :end_time => 1439, :days => segment.days )
          possibly_multiple_segment << Magnum::Segment.new( :id => segment.id, :start_time => 0, :end_time => new_end_time, :days => next_day(segment.days) )
        end

        if(start_time < 1439 && end_time <= 1439 )
          possibly_multiple_segment << Magnum::Segment.new( :id => segment.id, :start_time => start_time, :end_time => end_time, :days => segment.days )
        end

        possibly_multiple_segment
      end

      def next_day(days)
        shifted_days = days.to_i(2)
        tz_days = shifted_days & 1 == 1 ? (shifted_days >> 1 )| 64 : shifted_days >> 1
        return tz_days.to_s(2)
      end

      def time_range_covered?(segment, converted_segments)
        s_range = (segment.start_time.to_i..segment.end_time.to_i).to_a
        converted_segments.each do | c_seg |
          s_range -= s_range & (c_seg.start_time.to_i..c_seg.end_time.to_i).to_a
        end
        return s_range.size == 0 ? true : false
      end

      def allocation_covered?(segment, sp, sp_as_utc)
        ids = sp.tree.find_segment_node(segment.id).values.flatten
        alloc = sp.allocations.select{|x| ids.include?(x.id) }.map(&:value).uniq
        utc_alloc = sp_as_utc.allocations.select {|x| ids.include?(x.id) }.map(&:value).uniq
        return alloc == utc_alloc
      end
    end
  end
end
