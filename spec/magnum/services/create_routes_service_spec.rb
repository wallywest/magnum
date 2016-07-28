require 'spec_helper'

describe "Magnum::Service::CreateRoutes" do
    let(:sp)  {single_label_profile}
    let(:week) { Magnum::RouteSets::Week.translate(weekly)}

    let(:service_sp) {Magnum::Service::CreateRoutes.new(sp)}
    let(:service_week) {Magnum::Service::CreateRoutes.new(week)}

    let(:persistence) {double(:persistence)}
    let(:mock_routes) {
      double(:routes)
    }

    let(:mock_filter) {
      double(:filter)
    }
    
    context "super_profile" do
      it "should create persistence object based on routes and filter" do
        service_sp.stub(:filter).and_return(mock_filter)

        expect(sp).to receive(:build_routes).and_return(mock_routes)
        expect(Magnum::RoutePersistence).to receive(:new).with(mock_routes,mock_filter).and_return(persistence)
        expect(persistence).to receive(:save)

        service_sp.run
      end
    end

    context "weekly" do
      before do
        mock_label = Magnum::Label.new(:vlabel => "test",:id => 0)
        week.stub(:label).and_return(mock_label)
      end

      it "should create persistence object based on routes and filter" do
        service_week.stub(:filter).and_return(mock_filter)


        expect(week).to receive(:build_routes).and_return(mock_routes)
        expect(Magnum::RoutePersistence).to receive(:new).with(mock_routes,mock_filter).and_return(persistence)
        expect(persistence).to receive(:save)

        service_week.run
      end
    end
end
