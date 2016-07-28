require 'spec_helper'

describe "Activate", :type => :integration do
  before(:each) do
    Magnum.stub(:connection).and_return(Sequel::DATABASES.first)
  end

  let(:db) {Magnum.connection}

  MagnumTest.getValidSuperProfiles.each do | profile |
    puts profile["name"]
    profile.delete("_id")
    sp = Magnum::build(:super_profile, profile.to_json)

    describe "#{profile['name']} specs" do
      it "should write to yacc_routes table" do
        sp.activate({ update_tree: true })
        sp.labels.each do | l |
          next if l.isDelete
          routes = Magnum.connection[:yacc_route].where(route_name: l.vlabel).all
          expect(routes).to_not be_empty
        end
      end

      it "should write to yacc_routes_destinations_xref table" do
        sp.activate({ update_tree: true })
        sp.labels.each do | l |
          next if l.isDelete
          route = db[:yacc_route].where(route_name: l.vlabel).first
          xrefs = db[:yacc_route_destination_xref].where(route_id: route[:route_id]).all
          expect(xrefs).to_not be_empty
        end
      end

      it "should add up to 24 hours of a single day for a single vlabel" do
        sp.activate({ update_tree: true })
        sp.labels.each do | l |
          next if l.isDelete
          routes = db[:yacc_route].where(route_name: l.vlabel).all
          binaries = [128,64,32,16,8,4,2]
          group = {}
          routes.each do |route|
            binaries.each do |binary|
              day = route[:day_of_week] & binary
              next if day == 0
              g = group[day] ||= []
              g << (route[:begin_time]..route[:end_time])
              g.uniq!
            end
          end
          group.each do |day, ranges|
            sum = ranges.inject(0) do |s, r|
              s = s + r.count
            end
            expect(sum).to eq(1440)
          end
        end
      end

      it "should add up to all DOW (binary) for a single vlabel" do
        sp.activate({ update_tree: true })
        sp.labels.each do | l |
          next if l.isDelete
          routes = db[:yacc_route].where(route_name: l.vlabel).all
          bsum = routes.inject(0) do |b,route|
            b = b | route[:day_of_week]
          end
          expect(bsum).to eq(254)
        end
      end


      it "should have all yacc routes for a label equal 100%" do
        sp.activate({ update_tree: true })
        sp.labels.each do | l |
          next if l.isDelete
          routes = db[:yacc_route].where(route_name: l.vlabel).all.group_by{|x| x[:day_of_week]}
          routes.each do | dow, rrs |
            times = rrs.group_by{|x| (x[:begin_time]..x[:end_time])}
            times.values.each do |routes_range|
              pct = routes_range.inject(0){| totalpct, r | totalpct += r[:distribution_percentage] }
              expect(pct).to eq(100)
            end
          end
        end
      end
    end

  end
end
