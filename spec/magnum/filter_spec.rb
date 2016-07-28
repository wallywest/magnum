require 'spec_helper'

describe "Filter" do
  describe "routeFilter" do
    let(:params) {
      {:app_id => 8245, :route_name => "test label", :days => 254, :times => [[0,1439]]}
    }

    let(:params2) {
      {:app_id => 8245, :route_name => "test label", :days => 254, :times => [[1060,1439],[0,359]]}
    }

    it "should have a filter based on the segment" do
      filter = Magnum::Filter::routeFilter(params)

      expect(filter).to be_instance_of(Sequel::SQL::BooleanExpression)
      expect(filter.args.size).to eq(5)
      expect(filter.args[0].args).to eq([:route_name, "test label"])
      expect(filter.args[1].args).to eq([:app_id, 8245])
      expect(filter.args[2].args).to eq([:day_of_week, 254])
      expect(filter.args[3].args).to eq([:begin_time, 0])
      expect(filter.args[4].args).to eq([:end_time, 1439])
    end

    xit "should setup a boolean expression to filter the begin and end time" do
      filter = Magnum::Filter::routeFilter(params)

      expect(filter.args[3].args.size).to eq(1)
      sql = $DB[:test].literal(filter.args[3])
      expect(sql).to eq("(((`begin_time` = 0) AND (`end_time` = 1439)))")
    end

    xit "should correctly expand the time query for translated segments" do
      filter = Magnum::Filter::routeFilter(params2)

      expect(filter.args[3].args.size).to eq(4)
      sql = $DB[:test].literal(filter.args[3])
      expect(sql).to eq("(((`begin_time` = 1060) AND (`end_time` = 1439)) OR ((`begin_time` = 0) AND (`end_time` = 359)))")
    end
  end

  describe "treeFilter" do
  end
end


