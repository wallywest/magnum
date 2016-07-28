require 'spec_helper'

describe "TimeZone::Converter" do
  let(:profile)  {profile_multiple_segments}
  let(:profile2)  {profile_multiple_segments_different}
  let(:profile3)  {cst_profile}
  let(:profile4)  {cst_profile_different}


  it "should group segments by equal allocations" do
    Magnum::TimeZone::Converter.new(profile,"Central Time (US & Canada)")
    Magnum::TimeZone::Converter.new(profile3,"UTC")

    sets = profile.segments.group_by(&:equal_segs).keys
    cst_sets = profile3.segments.group_by(&:equal_segs).keys

    expect(sets).to eq([Set.new("1".."2")])
    expect(cst_sets).to eq([Set.new("1".."6")])
  end

  it "should split up groups without equal allocations" do
    Magnum::TimeZone::Converter.new(profile2,"Central Time (US & Canada)")
    Magnum::TimeZone::Converter.new(profile4,"UTC")
    sets = profile2.segments.group_by(&:equal_segs).keys
    cst_sets = profile4.segments.group_by(&:equal_segs).keys

    expect(sets).to eq([Set.new(["1"]),Set.new(["2"])])
    expect(cst_sets).to eq([Set.new(["1","5","6"]),Set.new(["2","3","4"])])
  end

  it "should return combinations for new segments" do
    segs = Magnum::TimeZone::Converter.new(profile2,"Central Time (US & Canada)").convert
    segs2 = Magnum::TimeZone::Converter.new(profile4,"UTC").convert

    seg = segs.first
    seg2 = segs.last
    seg3 = segs2.first
    seg4 = segs2.last
    expect(segs.size).to eq(2)
    expect(seg.set.to_a).to eq(["1"])
    expect(seg2.set.to_a).to eq(["2"])
    expect(seg.segments).to eq([[64, 0, 1439], [32, 0, 1079], [1, 1080, 1439]])
    expect(seg2.segments).to eq([[32, 1080, 1439], [30, 0, 1439], [1, 0, 1079]])

    expect(seg3.set.to_a).to eq(["1","5","6"])
    expect(seg4.set.to_a).to eq(["2","3","4"])
    expect(seg3.segments).to eq([[64, 0, 1439], [32, 0, 359], [1, 360, 1439]])
    expect(seg4.segments).to eq([[32, 360, 1439], [30, 0, 1439], [1, 0, 359]])
  end
end
