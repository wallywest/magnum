require 'spec_helper'

describe "RouteSets::Week" do
  let(:adr_profile) {utc_profile_adr}
  let(:adr_pkg) {Package.create(adr_profile.convertToPackage("1"))}
  let(:serialized) {Magnum::PackageSerializer.new(adr_pkg)}

  before(:each) do
    adr_pkg.stub(:vlabel_map).and_return(VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"}))
    mock_exit = double(:exit, :value => "123456789")
    RoutingExit.any_instance.stub(:exit_object).and_return(mock_exit)
  end

  it "should have model defined" do
    expect(Magnum::RouteSets::Week.model).to eq(Magnum::RouteSets::WeekModel)
  end

  it "should have represetner defined" do
    expect(Magnum::RouteSets::Week.representer).to eq(Magnum::RouteSets::WeekRepresenter)
  end


  describe "convert" do
    it "should return invoke parse on a new model" do
      mock_object = double(:week_model)

      expect(Magnum::PackageSerializer).to receive(:new).with(adr_pkg).and_return(serialized)
      expect(Magnum::RouteSets::WeekModel).to receive(:new).and_return(mock_object)
      expect(mock_object).to receive(:convert).with(serialized.as_json(root: :package)[:package])

      Magnum::RouteSets::Week.convert(adr_pkg)
    end
  end

end
