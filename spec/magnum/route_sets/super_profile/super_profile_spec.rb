require 'spec_helper'

describe "SuperProfileModel" do
  describe "SP" do
    let(:profile) {Magnum::RouteSets::SuperProfileModel.new(:time_zone => "UTC",:status => "new")}
    let(:profile2) {Magnum::RouteSets::SuperProfileModel.new(:time_zone => "Central Time (US & Canada)", :status => "new")}

    let(:label) {Magnum::Label.new(:id => "1", :vlabel => "12", :description => "wow")}
    let(:label2) {Magnum::Label.new(:id => "2", :vlabel => "13", :description => "wow")}
    let(:label3) {Magnum::Label.new(:id => "3", :vlabel => "11", :description => "wow")}

    let(:segment) {Magnum::Segment.new(:id => "1", :days => "1000001", :start_time => "0", :end_time => "1439")}
    let(:segment2) {Magnum::Segment.new(:id => "2", :days => "0111110", :start_time => "0", :end_time => "1439")}
    let(:segment3) {Magnum::Segment.new(:id => "3", :days => "1111111", :start_time => "0", :end_time => "1439")}

    let(:segment4) {Magnum::Segment.new(:id => "1", :days => "1000001", :start_time => "0", :end_time => "719")}
    let(:segment5) {Magnum::Segment.new(:id => "2", :days => "1000001", :start_time => "720", :end_time => "1439")}
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
        Magnum::Destination.new(:type => "Destination", :destination_id => "2"),
        Magnum::Destination.new(:type => "Destination", :destination_id => "4"),
        Magnum::Destination.new(:type => "Destination", :destination_id => "5"),
        Magnum::Destination.new(:type => "VlabelMap", :destination_id => "5")
      ]
    }

    let(:allocation) {Magnum::Allocation.new(:percentage => "2",:id => "1", :destinations => adr1)}
    let(:allocation2) {Magnum::Allocation.new(:percentage => "97", :id => "2", :destinations => adr2)}
    let(:allocation3) {Magnum::Allocation.new(:percentage => "0", :id => "3", :destinations => adr1)}


    before(:each) do
      Magnum::Destination.any_instance.stub(:value).and_return("123456790")
    end

    describe "defaults" do
      it "should have a blank tree" do
        expect(profile.tree).to be_instance_of(Magnum::SuperProfileTree)
        expect(profile.empty?).to eq(true)
      end
      it "should not be empty after modification" do
        profile.stub(:labels).and_return([1])
        expect(profile.empty?).to eq(false)
      end
    end

    describe "segments" do
      context "add segment" do
        it "should add new segment data to data array" do
          profile.add_segment(segment)
          expect(profile.segments).to eq([segment])
        end

        it "should add reference to tree" do
          profile.add_segment(segment)
          tree_segments = profile.tree.mapping
          expect(tree_segments).to eq({segment.id => {}})
        end

        it "should copy label reference hash to new segment" do
          profile.add_label(label)
          profile.add_label(label2)
          profile.add_segment(segment)
          tree_segments = profile.tree.mapping
          segment = tree_segments["1"]

          expect(segment.keys).to eq([label.id,label2.id])
        end
      end

      context "remove segment" do
        before(:each) do
          profile.add_segment(segment)
          profile.add_segment(segment2)
        end

        it "should remove segment from data array" do
          profile.remove_segment(segment)
          expect(profile.segments).to eq([segment2])
        end

        it "should remove reference in tree" do
          profile.remove_segment(segment)
          tree_segments = profile.tree.mapping

          expect(tree_segments.keys).to eq([segment2.id])
        end
      end

      context "clone segment" do
        before(:each) do
          profile.add_segment(segment)
          profile.add_segment(segment2)
          profile.add_label(label)
          profile.add_label(label2)
          profile.add_label(label3)
          profile.add_allocation(segment,label,allocation)
          profile.add_allocation(segment,label2,allocation2)
        end

        it "should not duplicate the ids" do
          profile.clone_segment(segment,segment2)
          ids_1 = profile.tree.mapping[segment.id].values.flatten
          ids_2 = profile.tree.mapping[segment2.id].values.flatten

          expect(ids_2).to_not eq(ids_1)
        end

        it "should clone label tree to another segment" do
          profile.clone_segment(segment,segment2)
          ids_1 = profile.tree.mapping[segment.id].values.flatten
          ids_2 = profile.tree.mapping[segment2.id].values.flatten
          allocation_1 = profile.find_allocation(ids_1.first)
          allocation_2 = profile.find_allocation(ids_2.first)
          expect(allocation_1.percentage).to eq(allocation_2.percentage)
          expect(allocation_1.destinations).to eq(allocation_2.destinations)
        end

      end
    end

    describe "labels" do
      before(:each) do
        profile.add_segment(segment)
        profile.add_segment(segment2)
      end

      context "add new label" do
        it "should create new label" do
          profile.add_label(label)
          expect(profile.labels.size).to eq(1)
        end

        it "should add label references in the tree" do
          profile.add_label(label)
          profile.add_label(label2)
          profile.add_label(label3)
          tree_segment_1 = profile.tree.mapping[segment.id]
          tree_segment_2 = profile.tree.mapping[segment2.id]

          expect(tree_segment_1.keys).to eq([label.id,label2.id,label3.id])
          expect(tree_segment_2.keys).to eq([label.id,label2.id,label3.id])
          expect(tree_segment_1).to eq(tree_segment_2)
        end
      end

      context "remove label" do
        it "should remove label" do
          profile.add_label(label)
          profile.add_label(label2)
          profile.add_label(label3)
          profile.remove_label(label3)

          expect(profile.labels.size).to eq(2)
        end

        it "should remove references in the tree" do
          profile.add_label(label)
          profile.add_label(label2)
          profile.add_label(label3)
          profile.remove_label(label3)

          tree_segment_1 = profile.tree.mapping[segment.id]
          tree_segment_2 = profile.tree.mapping[segment2.id]

          expect(tree_segment_1.keys).to eq([label.id,label2.id])
          expect(tree_segment_2.keys).to eq([label.id,label2.id])
          expect(tree_segment_1).to eq(tree_segment_2)
        end
      end
    end

    describe "allocations" do
      before(:each) do
        profile.add_segment(segment)
        profile.add_segment(segment2)
        profile.add_label(label)
        profile.add_label(label2)
        profile.add_label(label3)
      end

      context "add allocation" do
        it "should add a new allocation to single vlabel" do
          profile.add_allocation(segment,label,allocation)
          profile.add_allocation(segment,label2,allocation2)
          profile.add_allocation(segment,label2,allocation3)

          tree_segment_1 = profile.tree.mapping[segment.id]

          allocation_1 = tree_segment_1[label.id]
          allocation_2 = tree_segment_1[label2.id]
          allocation_3 = tree_segment_1[label3.id]

          expect(allocation_1).to eq([allocation.id])
          expect(allocation_2).to eq([allocation2.id,allocation3.id])
          expect(allocation_3).to eq([])
        end
      end

      context "remove allocation" do
        it "should remove allocation for single vlabel" do
          profile.add_allocation(segment,label,allocation)
          profile.add_allocation(segment,label2,allocation2)
          profile.add_allocation(segment,label2,allocation3)

          profile.remove_allocation(segment,label,allocation)
          tree_segment_1 = profile.tree.mapping[segment.id]
          allocation_1 = tree_segment_1[label.id]

          expect(allocation_1).to eq([])
        end
      end
    end

    describe "json" do
      before do
        profile2.add_segment(segment)
        profile2.add_segment(segment2)
        profile2.add_label(label)
        profile2.add_allocation(segment,label,allocation)
        profile2.extend(Magnum::RouteSets::SuperProfileRepresenter)
        @json = profile2.to_json
      end

      it "should be representable as json" do
        expect(@json).to_not eq("")
      end

      it "should translate the json back into the model object" do
        sp = Magnum::RouteSets::SuperProfileModel.new.extend(Magnum::RouteSets::SuperProfileRepresenter).from_json(@json)
        #expect(sp.labels).to eq(profile2.labels)
        expect(sp.tree.mapping).to eq(profile2.tree.mapping)
      end
    end
  end
end
