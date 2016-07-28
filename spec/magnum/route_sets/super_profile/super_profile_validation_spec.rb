require 'spec_helper'

describe "SuperProfile::Validations" do
  let(:sp) {invalid_super_profile}

  before(:each) do
    sp.stub(:persisted_vlabels).and_return(true)
    sp.stub(:persisted_destinations).and_return(true)
    @company = double(:company)
    @company.stub(:queuing_active?).and_return(false)
    Company.stub(:find).with(sp.app_id).and_return(@company)
  end

  describe "tree" do
    it "should receive tree validations" do
      sp.should_receive(:validate_mapping_keys)
      sp.should_receive(:validate_segments_have_all_labels)
      sp.should_receive(:validate_total_percentage_of_allocations)

      sp.valid?
    end

    it "should not throw an error for a valid tree" do
      sp.stub(:total_segment_days).and_return(true)
      sp.stub(:persisted_destinations).and_return(true)
      sp.stub(:adr_destinations).and_return(true)
      sp.stub(:persisted_vlabels).and_return(true)
      sp.stub(:total_day_ranges).and_return(true)
      sp.stub(:validate_total_percentage_of_allocations).and_return(true)
      sp.valid?

      expect(sp.errors.full_messages).to be_empty
    end

    it "should be invalid for any missing keys" do
      tree = Magnum::SuperProfileTree.new({1010101 => {12313131 => []}, "%" => {10 => [1313131]}})
      sp.stub(:tree).and_return(tree)

      sp.valid?
      expect(sp.errors.full_messages).to include("Tree must have valid keys")
    end
    
    it "should validate segments have all labels" do
      tree = Magnum::SuperProfileTree.new({1 => {1 => [1]}})
      label = Magnum::Label.new(:id => 1, :vlabel => "12", :description => "wow")
      label2 = Magnum::Label.new(:id => 2, :vlabel => "13", :description => "wow")
      sp.stub(:labels).and_return([label,label2])
      sp.stub(:tree).and_return(tree)

      sp.valid?
      expect(sp.errors.full_messages).to include("Segments must contain all labels in the tree")
    end

    it "should be invalid for any allocations that are not 100%" do
      tree = Magnum::SuperProfileTree.new({1 => {1 => [1]}})
      sp.stub(:tree).and_return(tree)

      sp.valid?
      expect(sp.errors.full_messages).to include("Allocations must equal 100% coverage")
    end
  end
end
