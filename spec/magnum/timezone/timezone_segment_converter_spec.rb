require 'spec_helper'

describe "TimeZone::SegmentConverter" do
  let(:segment) {Magnum::Segment.new(:id => 1, :days => "0000011", :start_time => "0", :end_time => "1439")}
  let(:segment2) {Magnum::Segment.new(:id => 2, :days => "1111100", :start_time => "0", :end_time => "1439")}
  let(:segment3) {Magnum::Segment.new(:id => 3, :days => "1010100", :start_time => "0", :end_time => "1439")}

  let(:segment4) {Magnum::Segment.new(:id => 3, :days => "1100000", :start_time => "600", :end_time => "659")}
  let(:segment5) {Magnum::Segment.new(:id => 3, :days => "1000011", :start_time => "900", :end_time => "1259")}

  let(:segments) {[segment,segment2,segment3,segment4,segment5]}

  it "should populate the standard offset" do
    range = Magnum::TimeZone::SegmentConverter.new(segment)

    range.should_receive(:standard_offset).with("UTC")
    range.should_receive(:apply_offset)

    range.convert_timezone("UTC")
  end

  describe "standard_offset" do
    it "shifts forward one hour" do
      segment.stub(:time_zone).and_return("Central Time (US & Canada)")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("Eastern Time (US & Canada)")

      expect(offset).to eq(60)
    end
    
    it "shifts back one hour" do
      segment.stub(:time_zone).and_return("Eastern Time (US & Canada)")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("Central Time (US & Canada)")

      expect(offset).to eq(-60)
    end
    
    it "shifts by zero" do
      segment.stub(:time_zone).and_return("Eastern Time (US & Canada)")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("Eastern Time (US & Canada)")

      expect(offset).to eq(0)
    end
    
    it "shifts fractionally" do
      segment.stub(:time_zone).and_return("Hawaii")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("Darwin")

      expect(offset).to eq(1170)
    end
    
    it "shifts by maximum possible offset" do
      segment.stub(:time_zone).and_return("International Date Line West")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("Nuku'alofa")

      expect(offset).to eq(1440)
    end
    
    it "shifs from a non-DST zone to a non-DST zone" do
      segment.stub(:time_zone).and_return("Hawaii")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("UTC")

      expect(offset).to eq(600)
    end

    it "shifts from a DST zone to a non-DST zone" do
      segment.stub(:time_zone).and_return("Central Time (US & Canada)")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("Hawaii")

      expect(offset).to eq(-240)
    end
    
    it "shifts from a non-DST zone to a DST zone" do
      segment.stub(:time_zone).and_return("UTC")
      range = Magnum::TimeZone::SegmentConverter.new(segment)
      offset = range.standard_offset("Central Time (US & Canada)")

      expect(offset).to eq(-360)
    end
  end

end

