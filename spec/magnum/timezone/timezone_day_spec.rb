require 'spec_helper'

describe "TimeZone::Days" do
  let(:segment) {Magnum::Segment.new(:id => 1, :days => "0000011", :start_time => "0", :end_time => "1439")}
  let(:segment2) {Magnum::Segment.new(:id => 2, :days => "1111100", :start_time => "0", :end_time => "1439")}
  let(:segment3) {Magnum::Segment.new(:id => 3, :days => "1010100", :start_time => "0", :end_time => "1439")}

  let(:segment4) {Magnum::Segment.new(:id => 4, :days => "1100000", :start_time => "600", :end_time => "659")}
  let(:segment5) {Magnum::Segment.new(:id => 5, :days => "1000011", :start_time => "900", :end_time => "1259")}
  let(:segment6) {Magnum::Segment.new(:id => 6, :days => "1000000", :start_time => "0", :end_time => "1439")}
  let(:segment7) {Magnum::Segment.new(:id => 6, :days => "0000001", :start_time => "0", :end_time => "1439")}

  it "select correct days from bitfield" do
    days = Magnum::TimeZone::Days.new(segment)
    days2 = Magnum::TimeZone::Days.new(segment2)
    days3 = Magnum::TimeZone::Days.new(segment3)
    days4 = Magnum::TimeZone::Days.new(segment4)
    days5 = Magnum::TimeZone::Days.new(segment5)

    names = days.selected_days.map(&:name)
    names2 = days2.selected_days.map(&:name)
    names3 = days3.selected_days.map(&:name)
    names4 = days4.selected_days.map(&:name)
    names5 = days5.selected_days.map(&:name)

    expect(names).to eq(["friday","saturday"])
    expect(names2).to eq(["sunday", "monday", "tuesday", "wednesday", "thursday"])
    expect(names3).to eq(["sunday", "tuesday", "thursday"])
    expect(names4).to eq(["sunday", "monday"])
    expect(names5).to eq(["sunday", "friday", "saturday"])
  end
  
  it "should breakout the segments into denormalized weekly minute ranges" do
    range1 = Magnum::TimeZone::Days.new(segment).ranges.map{|r| [r.start,r.end]}
    range2 = Magnum::TimeZone::Days.new(segment2).ranges.map{|r| [r.start,r.end]}
    range3 = Magnum::TimeZone::Days.new(segment3).ranges.map{|r| [r.start,r.end]}
    range4 = Magnum::TimeZone::Days.new(segment4).ranges.map{|r| [r.start,r.end]}
    range5 = Magnum::TimeZone::Days.new(segment5).ranges.map{|r| [r.start,r.end]}

    expect(range1).to eq([[7200, 8639], [8640, 10079]])
    expect(range2).to eq([[0, 1439], [1440, 2879], [2880, 4319], [4320, 5759], [5760, 7199]])
    expect(range3).to eq([[0, 1439], [2880, 4319], [5760, 7199]])
    expect(range4).to eq([[600, 659], [2040, 2099]])
    expect(range5).to eq([[900, 1259], [8100, 8459], [9540, 9899]])
  end

  context "apply offsets" do
    it "split create new UTC ranges for offsets" do
      #friday/saturday
      days = Magnum::TimeZone::Days.new(segment)
      days.apply_offset(60)

      #sunday
      days2 = Magnum::TimeZone::Days.new(segment6)
      days2.apply_offset(-60)

      days3 = Magnum::TimeZone::Days.new(segment6)
      days3.apply_offset(-1440)

      days4 = Magnum::TimeZone::Days.new(segment7)
      days4.apply_offset(1440)

      expect(days.utc_ranges[64].size).to eq(1)
      expect(days.utc_ranges[2].size).to eq(1)
      expect(days.utc_ranges[1].size).to eq(2)

      expect(days2.utc_ranges[64].size).to eq(1)
      expect(days2.utc_ranges[1].size).to eq(1)

      expect(days3.utc_ranges[1].size).to eq(1)
      expect(days4.utc_ranges[64].size).to eq(1)
    end
  end
end

