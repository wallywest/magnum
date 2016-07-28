require 'spec_helper'

describe "Magnum::Service::DeleteRoutes" do
  let(:sp_deletes) {profile_with_deletes}

  let(:service2) {Magnum::Service::DeleteRoutes.new(sp_deletes)}

  before(:each) do
    Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
  end

  it "should limit the labels to those that are flagged as isDelete" do
    expect(service2.labels).to_not eq(sp_deletes.labels)
  end

  it "should return a label with isdeleted flag" do
    expect(service2.labels.size).to eq(3)
    expect(service2.labels.first).to eq(sp_deletes.find_label("97"))
  end

  it "should build the routes to modify" do
    expect(service2.routes.size).to eq(3)
    expect(service2.routes.first).to eq(
      Magnum::Route.new(8245,"label_97","","","","")
    )
  end

  it "should setup teh correct filter based on routes" do
    filter = service2.filter
    expect(filter.args.first.args).to eq([:route_name, ["label_97","label_98","label_99"]])
    expect(filter.args.last.args).to eq([:app_id, 8245])
  end

  describe "run" do
    it "should execute teh service" do
      persistence = double(:persistence)
      expect(Magnum::RoutePersistence).to receive(:new).with(service2.routes,service2.filter).and_return(persistence)
      expect(persistence).to receive(:delete_routes).with(false)

      service2.run
    end
  end
end


