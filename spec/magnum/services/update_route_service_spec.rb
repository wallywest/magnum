require 'spec_helper'

describe Magnum::Service::UpdateRoute do
  let(:sp) {simple_profile}
  let(:params) {{ labels: [label0, label1], segment: { start_time: 0, end_time: 1439, days: '1111111', id: '1' }}}

  let(:label0) {{ id: '1', vlabel: 'label_1', description: 'whoa', allocations: [allocation0] }}
  let(:label1) {{ id: '2', vlabel: 'label_2', description: 'whoa', allocations: [allocation1] }}
  let(:allocation0) {{ 'id' => 'fb191190-3fed-11e3-9e90-3da0b6f30b3d', 'percentage' => '100', 'destinations' => [destination] }}
  let(:allocation1) { allocation0.merge('id' => 'fb191190-3fed-11e3-9e90-3da0b6f31234') }
  let(:destination) {{ 'id' => 3, 'destination_id' => 3, 'type' => 'Destination', 'dequeue' => '', 'value' => '1234567890' }}

  let(:service) { Magnum::Service::UpdateRoute.new(sp,params) }

  before :each do
    allow(Magnum).to receive(:connection).and_return Sequel::DATABASES.first
    allow_any_instance_of(Magnum::Destination).to receive(:value).and_return destination['value']
    allow_any_instance_of(Magnum::Segment).to receive(:time_zone).and_return sp.time_zone
  end

  it 'builds the routes to modify' do
    expect(service.routes.size).to be 2

    service.routes.each_with_index do |route, index|
      route_allocation = route.allocations.first.as_json
      expect(route).to be_instance_of(Magnum::Route)
      expect(route.route_name).to eq send("label#{index}")[:vlabel]
      expect(route_allocation).to eq send("allocation#{index}")
    end
  end

  it 'sets up the correct filter based on routes' do
    filter = service.filter
    expect(filter.args[0].args).to match_array [:route_name, [label0[:vlabel], label1[:vlabel]]]
    expect(filter.args[1].args).to match_array [:app_id, 8245]
  end

  describe '#run' do
    it 'executes the service' do
      persistence = double(:persistence)
      expect(Magnum::RoutePersistence).to receive(:new).with(service.routes,service.filter).and_return persistence
      expect(persistence).to receive :save

      service.run
    end
  end

  describe '#labels' do
    context 'when options[:labels] is nil' do
      before :each do
        params[:labels] = nil
      end

      it 'returns an empty array' do
        expect(service.send(:labels)).to eq []
      end

      context 'when options[:labels] is not nil' do
        it 'returns options[:labels]' do
          expect(service.send(:labels)).to be params[:labels]
        end
      end
    end
  end
end


