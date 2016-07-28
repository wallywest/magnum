module ProfileHelpers
  def conversion_case
    MagnumTest.getProfile("conversion")
  end

  def profile_with_deletes
    MagnumTest.getProfile("label_deletes")
  end

  def bug_case
    MagnumTest.getProfile("bug_case")
  end

  def utc_profile_adr
    MagnumTest.getProfile("utc_profile_adr")
  end

  def utc_profile_adr_dequeue
    MagnumTest.getProfile("utc_profile_adr_dequeue")
  end

  def utc_profile_different
    MagnumTest.getProfile("utc_profile_different")
  end

  def gmt_profile
    MagnumTest.getProfile("gmt_profile")
  end

  def gmt_profile_weird
    MagnumTest.getProfile("gmt_profile_weird")
  end


  def single_label_profile
    MagnumTest.getProfile("utc_profile_simple")
  end

  def profile_multiple_segments
    MagnumTest.getProfile("utc_profile_segments")
  end

  def profile_multiple_segments_different
    MagnumTest.getProfile("utc_profile")
  end

  def simple_profile
    MagnumTest.getProfile("utc_profile_labels")
  end

  def invalid_super_profile
    MagnumTest.getProfile("invalid_utc_profile")
  end

  def split_range_segments
    segment = Magnum::Segment.new(:id => 1, :days => "1111111", :start_time => "0", :end_time => "719")
    segment2 = Magnum::Segment.new(:id => 2, :days => "1111111", :start_time => "720", :end_time => "859")
    segment3 = Magnum::Segment.new(:id => 3, :days => "1111111", :start_time => "860", :end_time => "1439")

    [segment,segment2,segment3]
  end

  def invalid_split_range_segments
    segment = Magnum::Segment.new(:id => 1, :days => "1111111", :start_time => "0", :end_time => "700")
    segment2 = Magnum::Segment.new(:id => 2, :days => "1111111", :start_time => "720", :end_time => "800")
    segment3 = Magnum::Segment.new(:id => 3, :days => "1111111", :start_time => "860", :end_time => "1000")

    [segment,segment2,segment3]
  end

  def cst_profile
    MagnumTest.getProfile("cst_profile")
  end

  def cst_profile_different
    MagnumTest.getProfile("cst_profile_split")
  end

end
