module MappingHelpers
  def simple_mapping
    seg = Magnum::TimeZone::Days::UTCSegment.new(0,1439)
    seg2 = Magnum::TimeZone::Days::UTCSegment.new(0,1079)
    seg3 = Magnum::TimeZone::Days::UTCSegment.new(1080,1439)
    mapping = {
      64 => [seg],
      32 => [seg2,seg3]
    }
    mapping
  end

  def complex_mapping
    seg = Magnum::TimeZone::Days::UTCSegment.new(0,1439)
    seg2 = Magnum::TimeZone::Days::UTCSegment.new(0,1079)
    seg3 = Magnum::TimeZone::Days::UTCSegment.new(1080,1439)
    mapping = {
      64 => [seg],
      32 => [seg2,seg3],
      16 => [seg],
      8 => [seg],
      4 => [seg],
      2 => [seg2,seg3],
      1 => [seg]
    }
    mapping
  end

  def split_group_unsorted
    seg2 = Magnum::TimeZone::Days::UTCSegment.new(10,20)
    seg3 = Magnum::TimeZone::Days::UTCSegment.new(7,8)
    seg4 = Magnum::TimeZone::Days::UTCSegment.new(1,2)
    [seg2,seg3,seg4]
  end

  def split_group_c
    seg2 = Magnum::TimeZone::Days::UTCSegment.new(0,1079)
    seg3 = Magnum::TimeZone::Days::UTCSegment.new(1080,1439)
    [seg2,seg3]
  end

  def split_group_s
    seg2 = Magnum::TimeZone::Days::UTCSegment.new(0,719)
    seg3 = Magnum::TimeZone::Days::UTCSegment.new(1080,1439)
    [seg2,seg3]
  end
end

