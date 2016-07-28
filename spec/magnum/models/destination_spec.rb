require 'spec_helper'

describe "Magnum::Destinations" do
  it "should set the default value of dequeue to empty string" do
    d = Magnum::Destination.new(destination_id: 1, type: "Destination", value: "blah")
    expect(d.dequeue).to eq("")
  end
end
