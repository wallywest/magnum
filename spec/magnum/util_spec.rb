require 'spec_helper'

describe "util" do
  let(:sp)  {utc_profile_adr}

  describe "padding" do
    it "should bad the binary values based on length given" do
      value = sp.padding(7,"10")
      value2 = sp.padding(7,"1")
      value3 = sp.padding(7,"1000001")
      expect(value).to eq('0000010')
      expect(value2).to eq('0000001')
      expect(value3).to eq('1000001')
    end
  end

  describe "find_label" do
    it "should return the segment from given id" do
      label = sp.find_label("1")
      expect(label).to be_instance_of(Magnum::Label)
    end
  end

  describe "find_segment" do
    it "should return the segment from given id" do
      segment = sp.find_segment("1")
      expect(segment).to be_instance_of(Magnum::Segment)
    end
  end

  describe "equalAllocations" do
    it "should return true for equal allocations" do
      expect(sp.equalAllocation("1","2")).to eq(true)
    end

    it "should return false for unequal allocations" do
      expect(sp.equalAllocation("1","3")).to eq(false)
    end
  end

  describe "yacc_row" do
    it "should return a row for yacc" do
      segment = sp.segments.first
      segment.time_zone = "UTC"
      label = sp.labels.first

      expect(sp.yacc_row(segment,label)).to eq([{
        :day_of_week => 62,
        :begin_time => 0,
        :end_time => 1439,
        :app_id => 8245,
        :route_name => "label_1"
      }])
    end

    it "should convert the yacc row to utc" do
      pending
      segment = sp.segments.first
      label = sp.labels.first
      segment.time_zone = "Central Time (US & Canada)"
      expect(sp.yacc_row(segment,label)).to eq({})

    end
  end

end
