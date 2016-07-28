require 'spec_helper'

describe "Segments" do
  let(:utc_segment) {Magnum::Segment.new(:id => 1, :days => "0000011", :start_time => "0", :end_time => "1439",:time_zone => "UTC")}
  let(:cent_segment) {Magnum::Segment.new(:id => 1, :days => "0000011", :start_time => "0", :end_time => "1439")}
  let(:segment2) {Magnum::Segment.new(:id => 2, :days => "1111100", :start_time => "0", :end_time => "1439")}

  let(:utc_seg1) {Magnum::TimeZone::Days::UTCSegment.new(0,359)}
  let(:utc_seg2) {Magnum::TimeZone::Days::UTCSegment.new(360,1439)}
  let(:utc_seg3) {Magnum::TimeZone::Days::UTCSegment.new(720,1439)}
  let(:utc_seg4) {Magnum::TimeZone::Days::UTCSegment.new(360,719)}
  let(:utc_seg5) {Magnum::TimeZone::Days::UTCSegment.new(1100,1439)}

  describe "utc_segments" do
    it "should build utc segments for the segment" do
      utc_segment.time_zone = "UTC"
      segment2.time_zone = "UTC"
      utc_segment.build_utc_segments
      segment2.build_utc_segments

      expect(utc_segment.utc_segments[1].size).to eq(1)
      expect(utc_segment.utc_segments[2].size).to eq(1)
      expect(utc_segment.utc_segments[8].size).to eq(0)

      expect(segment2.utc_segments[1].size).to eq(0)
      expect(segment2.utc_segments[4].size).to eq(1)
      expect(segment2.utc_segments[8].size).to eq(1)
      expect(segment2.utc_segments[16].size).to eq(1)
      expect(segment2.utc_segments[32].size).to eq(1)
      expect(segment2.utc_segments[64].size).to eq(1)
    end

    it "should convert utc segments from different time zone" do
      utc_segment.build_utc_segments
      cent_segment.time_zone = "Central Time (US & Canada)"
      cent_segment.build_utc_segments

      expect(utc_segment.utc_segments).to_not eq(cent_segment.utc_segments)
      expect(cent_segment.utc_segments[1].size).to eq(1)
      expect(cent_segment.utc_segments[2].size).to eq(1)
      expect(cent_segment.utc_segments[64].size).to eq(1)
    end
  end

  describe "translate segment" do
    it "should return back flattened segments" do
      cent_segment.time_zone = "Central Time (US & Canada)"
      segs = cent_segment.translate_segment("UTC")

      expect(segs[1].size).to eq(1)
      expect(segs[2].size).to eq(1)
      expect(segs[64].size).to eq(1)
    end
  end

  describe "merge" do
    it "should merge consecutive values into one representation" do
      values = [utc_seg1,utc_seg2]
      utc_segment.merge(values)

      expect(values).to eq([Magnum::TimeZone::Days::UTCSegment.new(0,1439)])
    end
    it "should not merge nonconsecutive values" do
      values = [utc_seg1,utc_seg3]
      utc_segment.merge(values)

      expect(values).to eq([utc_seg1,utc_seg3])
    end

    it "should keep all nonconsecutive pairs" do 
      values = [utc_seg1,utc_seg4,utc_seg5]
      utc_segment.merge(values)

      expect(values).to eq([ Magnum::TimeZone::Days::UTCSegment.new(0,719),utc_seg5])
    end
  end
end
 
