require 'spec_helper'

describe "RouteSets" do
  it "should include a registry of registered routeset types" do
    expect(Magnum::RouteSets.types).to eq({
      :week=>Magnum::RouteSets::Week,
      :super_profile=>Magnum::RouteSets::SuperProfile
    })
  end
end

