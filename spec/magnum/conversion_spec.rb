require 'spec_helper'

describe "Tree" do
  describe "mergePackage" do
    let(:profile)  {single_label_profile}
    let(:profile3)  {profile_multiple_segments}
    let(:adr_profile)  {utc_profile_adr}
    let(:adr_profile_dq) {utc_profile_adr_dequeue}
    before do
      mock_exit = double(:exit, :value => "123456789")
      RoutingExit.any_instance.stub(:exit_object).and_return(mock_exit)
    end

    context "when using queue/dequeues" do
      before do
        @pkg = Package.create(adr_profile_dq.convertToPackage("1"))
        @pkg.stub(:vlabel_map).and_return(VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"}))
      end

      it "should include dequeue labels" do
        sp = Magnum::RouteSets::SuperProfileModel.new
        sp.mergePackage(@pkg)

        dest_with_dequeues = sp.allocations[0].destinations
        expect(dest_with_dequeues.map(&:dequeue).uniq).to eq(["dq_Route"])
        expect(dest_with_dequeues.map(&:requires_dequeue).uniq).to eq([true])
      end
    end

    context "when basic example" do
      before(:each) do
        @adr_pkg = Package.create(adr_profile.convertToPackage("1"))
        @adr_pkg.stub(:vlabel_map).and_return(VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"}))
        @non_adr_pkg = Package.create(adr_profile.convertToPackage("2"))
        @non_adr_pkg.stub(:vlabel_map).and_return(VlabelMapSequel.load({:vlabel_map_id => "2", :vlabel => "label_2", :description => "whoa"}))
      end

      it "should allow a merge of unequal segments when new SP" do
        sp = Magnum::RouteSets::SuperProfileModel.new
        sp.mergePackage(@adr_pkg)
        expect(sp.labels).to_not eq([])
        expect(sp.segments).to_not eq([])
        expect(sp.allocations).to_not eq([])
        expect(sp.tree).to_not eq({})
      end

      it "should not allow a merge of unequal segments" do
        pkg_attrs = profile3.extractPackage("1")
        pkg = Package.create(pkg_attrs)
        pkg.stub(:vlabel_map).and_return(VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"}))

        expect{profile.mergePackage(pkg)}.to raise_error(Magnum::Error, "Error importing label.  Please make sure the time segments for this label match those in this Super Profile.")
      end

      it "should merge adrs as well" do
        sp = Magnum::RouteSets::SuperProfileModel.new
        sp.mergePackage(@adr_pkg)
        sp.mergePackage(@non_adr_pkg)
        allocations = sp.allocations

        expect(allocations.size).to eq(6)
        expect(allocations.last.destinations.size).to eq(4)
        #add in better method to find allocations by vlabel
        #expect(allocations.first.destinations.size).to eq(4)
      end

      it "should include the destination values in the allocation" do
        sp = Magnum::RouteSets::SuperProfileModel.new
        sp.mergePackage(@adr_pkg)
        allocation = sp.allocations.first
        values = allocation.destinations.map{|d| d.value}
        expect(values.uniq).to eq(["123456789"])
      end
    end
  end

  describe "extractPackage" do

    before(:each) do
      Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
    end

    let(:package)  {simple_profile}

    #it "should clone a superprofile and create 2 separate objects" do
      #pending
      ##clone = package.deepClone(package)
      ##expect(clone).to_not eq(package)
    #end

    it "should return the created hash" do
      pack = package.extractPackage("1")
      expect(pack.class).to eq(Hash)
      expect(package.labels.map(&:id)).to_not include(["1"])
    end
  end

  describe "convertToPackage" do

    before do
      Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
    end

    let(:adr_profile)  {utc_profile_adr}
    let(:adr_profile_with_dequeue) { utc_profile_adr_dequeue }

    let(:package_attributes) {adr_profile.convertToPackage("1")}
    let(:package_attributes_dq) {adr_profile_with_dequeue.convertToPackage("1")}
    let(:package) {Package.create(package_attributes)}
    let(:package_dq) {Package.create(package_attributes_dq)}

    before(:each) do
      #@pkg = utc_profile.convertToPackage("1")
      package.stub(:vlabel_map).and_return(VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"}))
    end

    it "should return a hash of the package attributes" do
      expect(package_attributes.class).to eq(Hash)
    end

    it "should have the correct profiles" do
      profiles = package.profiles

      profiles.each do |pf|
        expect(pf).to be_instance_of(::Profile)
      end
    end

    it "should have correct segments" do
      segments = package.profiles.first.time_segments

      segments.each do |seg|
        expect(seg).to be_instance_of(::TimeSegment)
      end
    end

    it "should have correct routings" do
      routings = package.profiles.first.time_segments.first.routings

      routings.each do |route|
        expect(route).to be_instance_of(::Routing)
      end

      expect(routings.size).to eq(1)

    end

    it "should have correct routing_exits and include adrs" do
      res = package.profiles.first.time_segments.first.routings.first.routing_exits

      expect(res.size).to eq(4)

      res.each_with_index do |re,index|
        expect(re).to be_instance_of(::RoutingExit)
        expect(re.call_priority).to eq(index+1)
      end
    end

    it "should have the correct routing_exits and include dequeues" do
      res = package_dq.profiles.first.time_segments.first.routings.first.routing_exits

      expect(res.map(&:dequeue_label).uniq).to eq(["dq_Route"])
    end
  end
end
