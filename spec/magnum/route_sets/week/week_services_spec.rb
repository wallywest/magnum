require 'spec_helper'

describe "magnum::routesets::weekservices" do
  let(:week) { Magnum::RouteSets::Week.translate(weekly)}

  before(:each) do
    Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
  end

  describe "activate" do
    it "should run the CreateRoutes service" do
      service = double(:service)

      expect(Magnum::Service::CreateRoutes).to receive("new").with(week).and_return(service)
      expect(service).to receive(:run)

      week.activate
    end
  end
end
