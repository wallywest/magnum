require 'spec_helper'

describe "More Activations" do
  before(:each) do
    Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
  end
  let(:db) {Magnum.connection}

  MagnumTest.getValidTimeZoneSuperProfiles.each do | profile |
    puts profile["name"]
    profile.delete("_id")
    current_profile = Magnum::build(:super_profile, profile.to_json)

    it "should have each original dow covered in the DB, #{profile['name']}" do
      current_profile.activate({ update_tree: true })
      routes = db[:yacc_route].where(route_name: current_profile.labels.first.vlabel).to_a

      dow_collection = routes.map {|x| x[:day_of_week]}.uniq
      current_profile.segments.each do | segment |
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
      current_profile.activate({ update_tree: true })
      routes = db[:yacc_route].where(route_name: current_profile.labels.first.vlabel).to_a
      tod_collection = routes.map {|x| [x[:day_of_week], x[:begin_time]..x[:end_time]] }


      current_profile.segments.each do | segment |
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
      current_profile.activate({ update_tree: true })
      routes = db[:yacc_route].where(route_name: current_profile.labels.first.vlabel).to_a

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
