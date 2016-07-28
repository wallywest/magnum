require 'spec_helper'

#why is this the slowest?
describe "More Activations" do
  before(:each) do
    Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
  end

  let(:db){Magnum.connection}

  profiles = MagnumTest.getValidTimeZoneSuperProfiles
  profiles.each do | profile |
    puts profile["name"]
    profile.delete("_id")

    it "should have each original dow covered in the DB, #{profile['name']}" do
      profile_built = Magnum::build(:super_profile, profile.to_json)
      pkg = Package.create(profile_built.convertToPackage("1"))
      @vlabel_map = VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"})
      pkg.stub(:vlabel_map).and_return(@vlabel_map)
      mock_exit = double(:exit, :value => "123456789")
      RoutingExit.any_instance.stub(:exit_object).and_return(mock_exit)
      @week = Magnum::convert(:week, pkg)

      @week.activate
      routes = db[:yacc_route].where(route_name: @vlabel_map.vlabel).to_a

      dow_collection = routes.map {|x| x[:day_of_week]}.uniq
      @week.segments.each do | segment |
        bsum = 0
        segment.utc_segments.each do | day, range |
          next if range.empty?
          bit_shifted_day = day << 1
          bsum = bsum | bit_shifted_day
        end

        is_covered = nil
        dow_collection.each do | dow |
          is_covered = true if(bsum & dow != 0)
        end

        expect(is_covered).to eq(true)
      end
    end

    it "should have each original tod covered in the DB, #{profile['name']}" do
      profile_built = Magnum::build(:super_profile, profile.to_json)
      pkg = Package.create(profile_built.convertToPackage("1"))
      @vlabel_map = VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"})
      pkg.stub(:vlabel_map).and_return(@vlabel_map)
      mock_exit = double(:exit, :value => "123456789")
      RoutingExit.any_instance.stub(:exit_object).and_return(mock_exit)
      @week = Magnum::convert(:week, pkg)

      @week.activate
      routes = db[:yacc_route].where(route_name: @vlabel_map.vlabel).to_a
      tod_collection = routes.map {|x| [x[:day_of_week], x[:begin_time]..x[:end_time]] }


      @week.segments.each do | segment |
        segment.utc_segments.each do | day, range |
        next if range.empty?
        range.each do | time_range |
          time_range_covered  = (time_range['start']..time_range['end'])

          tod_collection.each do | tod_range |
            bit_shifted_day = day << 1
            if(bit_shifted_day & tod_range[0] != 0)
              time_range_covered = time_range_covered.to_a - tod_range[1].to_a
            end
          end
          expect(time_range_covered).to eq([])
        end
        end
      end
    end

    it "should not overlap time segments in the DB, #{profile['name']}" do
      profile_built = Magnum::build(:super_profile, profile.to_json)
      pkg = Package.create(profile_built.convertToPackage("1"))
      @vlabel_map = VlabelMapSequel.load({:vlabel_map_id => 1, :vlabel => "wtf", :description => "wtf"})
      pkg.stub(:vlabel_map).and_return(@vlabel_map)
      mock_exit = double(:exit, :value => "123456789")
      RoutingExit.any_instance.stub(:exit_object).and_return(mock_exit)
      @week = Magnum::convert(:week, pkg)

      @week.activate
      routes = db[:yacc_route].where(route_name: @vlabel_map.vlabel).to_a

      routes.each do | route |
        routes.each do | inner_route |
          if(route != inner_route && route[:day_of_week] != inner_route[:day_of_week] && route[:day_of_week] & inner_route[:day_of_week] != 0)
            route_range = route[:begin_time]..route[:end_time]
            expect(route_range.cover? inner_route[:begin_time]).to be_falsey
            expect(route_range.cover? inner_route[:end_time]).to be_falsey
          end
        end
      end
    end

  end
end
