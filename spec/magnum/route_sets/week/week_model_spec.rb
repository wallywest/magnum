require 'spec_helper'

describe "RouteSets::Week::Model" do
  it "should include a week routeset type" do
    expect(Magnum::RouteSets.types).to include({
      :week => Magnum::RouteSets::Week
    })
  end

  describe "Model" do
    #it "should include default properties" do
      #routeset = Magnum::RouteSets::Week.model.new
      #expect(routeset.attributes).to eq({
        #:id=>nil,
        #:label=> nil,
        #:name=>nil,
        #:description=>nil,
        #:app_id=>nil,
        #:segments=>[],
        #:allocations=>[],
        #:time_zone=>"UTC",
        #:tree=>{}
      #})
    #end
   
    let(:profile) {Magnum::RouteSets::WeekModel.new(:time_zone => "UTC",:status => "new")}
    let(:json) {weekly}
    let(:object) { Magnum::RouteSets::Week.translate(json)}
    let(:mock_persistence) {double(:mock_persistence)}
   

    describe "defaults" do
      it "should have a blank tree" do
        expect(profile.tree).to be_instance_of(Magnum::WeekProfileTree)
      end
    end

    describe "#build_routes" do
      it "should return an array of translated segments to routes" do
        mock_label = Magnum::Label.new(:vlabel => "test",:id => 0)
        object.stub(:label).and_return(mock_label)
        routes = object.build_routes

        expect(routes.size).to eq(9)
        expect(routes[0].class).to eq(Magnum::Route)
      end
    end

    #describe "#filter" do
      #let(:label) {Magnum::Label.new(:vlabel => "test",:id => 0)}
      #before(:each) do
        #object.stub(:label).and_return(label)
      #end

      #it "should call the proper filter" do
        #expect(Magnum::Filter).to receive("treeFilter").with({:route_name=>"test", :app_id=>8245})
        #object.filter
      #end

      #it "should return a filter object" do 
        #filter = object.filter
        #expect(filter.class).to eq(Sequel::SQL::BooleanExpression)
      #end
    #end
  end

  describe "Representer" do
    let(:json) {weekly}
    
    it "convert json to a week model" do 
      object = Magnum::RouteSets::Week.translate(json)
      expect(object.class).to eq(Magnum::RouteSets::WeekModel)
    end
  end

  describe "Validations" do
    let(:json) {weekly}
    let(:object) { Magnum::RouteSets::Week.translate(json)}

    it "should include validations" do
      expect(object).to respond_to(:valid?)
    end
  end
end

