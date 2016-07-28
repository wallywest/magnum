require 'spec_helper'

describe "Magnum::Allocations" do
  let(:profile) {utc_profile_adr}

  let(:dequeue) {Magnum::Destination.new(:type => "VlabelMap", :destination_id => "5")}
  let(:adr1) {
    [
      Magnum::Destination.new(:type => "Destination", :destination_id => "1"),
      Magnum::Destination.new(:type => "Destination", :destination_id => "2"),
      Magnum::Destination.new(:type => "Destination", :destination_id => "3"),
      Magnum::Destination.new(:type => "VlabelMap", :destination_id => "1")
    ]
  }

  let(:adr2) {
    [
      Magnum::Destination.new(:type => "Destination", :destination_id => "2"),
      Magnum::Destination.new(:type => "Destination", :destination_id => "2"),
      Magnum::Destination.new(:type => "Destination", :destination_id => "3"),
      Magnum::Destination.new(:type => "VlabelMap", :destination_id => "1")
    ]
  }

  let(:adr3) {
    [
      Magnum::Destination.new(:type => "Destination", :destination_id => "2", :dequeue => "dequeue_label"),
      Magnum::Destination.new(:type => "Destination", :destination_id => "4"),
      Magnum::Destination.new(:type => "Destination", :destination_id => "5"),
      Magnum::Destination.new(:type => "VlabelMap", :destination_id => "5")
    ]
  }

  let(:allocation) {Magnum::Allocation.new(:percentage => "2",:id => 1, :destinations => adr1)}
  let(:allocation2) {Magnum::Allocation.new(:percentage => "97", :id => 2, :destinations => adr2)}
  let(:allocation3) {Magnum::Allocation.new(:percentage => "0", :id => 3, :destinations => adr1)}
  let(:allocation4) {Magnum::Allocation.new(:percentage => "0", :id => 4, :destinations => adr3)}
  let(:allocation5) {Magnum::Allocation.new(:percentage => "97", :id => 3, :destinations => adr2)}

  it "should default to a single destination value" do
    alloc = profile.allocations.last
    dest = Magnum::Destination.new(:type => "Destination", :destination_id => "5")
    expect(alloc.destinations.first.attributes).to eq(dest.attributes)
  end

  it "should have its value set" do
    alloc = profile.allocations.last


    expect(alloc.value).to eq(Set.new ["50",alloc.simple_destinations])
  end

  it "should have have adr objects assigned" do
    alloc = profile.allocations.first
    destination = alloc.destinations.first

    expect(destination).to be_instance_of(Magnum::Destination)
  end

  describe "tree equality" do
    it "should not be equal with different percentages" do
      expect(profile.equalAllocation("1","3")).to eq(false)
    end

    it "should have equal allocations" do
      expect(profile.equalAllocation("1","2")).to eq(true)
    end
  end

  describe "allocation equality" do
    it "should return false if percentages are different" do
      expect(allocation.equal(Set.new ["2",[]])).to eq(false)
    end

    it "should return false if destinations  are different" do
      expect(allocation3.equal(Set.new ["0",[]])).to eq(false)
    end

    it "should return true if percentages and destinations are equal" do
      destinations = [
        {:exit_type => "Destination", :exit_id => 1},
        {:exit_type => "Destination", :exit_id => 2},
        {:exit_type => "Destination", :exit_id => 3},
        {:exit_type => "VlabelMap", :exit_id => 1}
      ]

      expect(allocation3.equal(Set.new ["0",destinations])).to eq(true)
    end
  end

  describe "dequeue" do
    it "should return all dequeue values on each of its destinations" do
      expect(allocation4.dequeues).to eq(["dequeue_label"])
    end
  end
end
