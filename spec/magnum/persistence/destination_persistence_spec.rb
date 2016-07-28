require 'spec_helper'

describe "Destination Persistence" do

  let(:persistence) {
    Magnum::DestinationPersistence.new(mock_routes)
  }

  before do
    @mock_db = Sequel.mock(:fetch => [
      {:destination_id => 2, :dtype => "O"},
      {:destination_id => 1, :dtype => "M"}
    ])

    Magnum::stub(:connection).and_return(Sequel::DATABASES.first)
    @ds = Sequel.mock.dataset
  end

  it "should have uniq destination ids for the routes" do
    expect(persistence.destination_ids).to eq([1,2])
  end

  it "should create a query based on the destination ids" do

    persistence.stub(:yacc_destination).and_return(@ds)

    expect(@ds).to receive(:join).
      with(:yacc_destination_property, 
      {:app_id=>:app_id, :destination_property_name=>:destination_property_name}).
      and_return(@ds)
    expect(@ds).to receive(:where).with({:destination_id => [1,2]})

    persistence.load_destinations
  end


  it "should return the destination query grouped by dtype" do
    @ds = @mock_db[:t]
    persistence.stub(:load_destinations).and_return(@ds)
    group = persistence.group_by_dtype
    expect(group.keys).to eq(["O","M"])
    expect(group.values).to eq([[2],[1]])
  end

  it "should lookup the type of the destination" do
    @ds = @mock_db[:t]
    persistence.stub(:load_destinations).and_return(@ds)

    type1 = persistence.lookup_destination_type(1)
    type2 = persistence.lookup_destination_type(2)

    expect(type1).to eq("M")
    expect(type2).to eq("O")

  end
end

