require 'spec_helper'

describe "RouteSets::Week::Validation" do
  let(:week) {Magnum::RouteSets::Week.translate(weekly)}

  before do
    week.stub(:persisted_vlabels).and_return(true)
    week.stub(:persisted_destinations).and_return(true)
    @company = double(:company)
    @company.stub(:queuing_active?).and_return(false)
    Company.stub(:find).with(week.app_id).and_return(@company)
  end

  describe "validate_mapping_keys" do
    it "should return an error message with invalid segment keys" do
      flat = {["1010101"] => [], ["%"] => [1313131]}
      week.tree.stub(:flatten).and_return(flat)

      week.valid?
      expect(week.errors.full_messages).to include("Tree must have valid keys")
    end

    it "should return an error message with invalid allocation keys" do
      flat = {[1] => ["1"], ["2"] => ["818181818"]}
      week.tree.stub(:flatten).and_return(flat)

      week.valid?
      expect(week.errors.full_messages).to include("Tree must have valid keys")
    end
  end
end
