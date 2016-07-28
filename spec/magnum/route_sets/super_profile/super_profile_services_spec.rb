require 'spec_helper'

describe "services" do
  describe "activate" do
    let(:sp)  {simple_profile}
    let(:adr_profile) {utc_profile_adr}

    before(:each) do
      Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
    end

    it "should call update_route with update options" do
      options = {:update => true}
      service = double(:service)

      expect(Magnum::Service::UpdateRoute).to receive(:new).with(sp,options).and_return(service)
      expect(service).to receive(:run)
      expect(sp).to receive(:cleanup)

      sp.activate(options)
    end

    it "should call update_tree with no options" do
      options = {}
      service = double(:service)

      expect(Magnum::Service::CreateRoutes).to receive(:new).with(sp).and_return(service)
      expect(service).to receive(:run)
      expect(sp).to receive(:cleanup)


      sp.activate(options)
    end

    it "should call delete labels service" do
      service = double(:service)

      expect(Magnum::Service::DeleteRoutes).to receive(:new).with(sp,true).and_return(service)
      expect(service).to receive(:run)
      expect(sp).to receive(:cleanup)

      sp.delete_dirty_labels
    end
  end
end

