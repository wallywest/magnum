require 'spec_helper'

describe "TimeZone::RangesCollection" do
  let(:mapping) {simple_mapping}
  let(:mapping2) {complex_mapping}

  it "should group the ranges" do
    trange = Magnum::TimeZone::RangeCollection.new(mapping,[])
    trange2 = Magnum::TimeZone::RangeCollection.new(mapping2,[])

    expect(trange.binaries.to_a).to eq([96])
    expect(trange2.binaries.to_a).to eq([127])
  end

  it "should squash binaries with same ranges" do
    trange = Magnum::TimeZone::RangeCollection.new(mapping,[])
    trange2 = Magnum::TimeZone::RangeCollection.new(mapping2,[])

    expect(trange.segments).to eq([[96,0,1439]])
    expect(trange2.segments).to eq([[127,0,1439]])
  end


  describe "TimeZone:RangeGroup" do
    let(:group) {split_group_c}
    let(:bgroup) {split_group_s}

    it "should sort the ranges" do
      g = Magnum::TimeZone::RangeGroup.new(64,split_group_unsorted)
      expect(g.ranges).to eq([1..2, 7..8, 10..20])
    end

    it "should combine the consecutive ranges" do
      g = Magnum::TimeZone::RangeGroup.new(64,group)
      expect(g.ranges).to eq([0..1439])
    end

    it "should not combine the nonconsecutive ranges" do
      g = Magnum::TimeZone::RangeGroup.new(64,bgroup)
      expect(g.ranges).to eq([0..719, 1080..1439])
    end

  end
end

