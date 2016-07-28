require 'spec_helper'

describe "Magnum" do
  describe "build" do
    it "should raise an error for invalid type" do
      expect{
        Magnum::build(:wtf, "{}",{})
      }.to raise_error(Magnum::InvalidType)
    end

    it "should route set object based on type" do
      routeset = Magnum::build(:week, "{}", {})
      expect(routeset.class).to eq(Magnum::RouteSets::WeekModel)
    end

    it "should include the options" do
      routeset = Magnum::build(:week, "{}", {app_id: 8245})
      expect(routeset.app_id).to eq(8245)
    end

    it "should have the expected available type" do
      expect(Magnum::available_types).to eq([:week, :super_profile])
    end
  end
end

