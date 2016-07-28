module Magnum
  class Route < Struct.new(:app_id,
      :route_name,
      :day_of_week,
      :begin_time,
      :end_time,
      :allocations
   )
    def equal(row)
      (self.app_id  == row[:app_id] &&
      self.day_of_week == row[:day_of_week] &&
      self.route_name  == row[:route_name] &&
      self.begin_time == row[:begin_time] &&
      self.end_time == row[:end_time])
    end

    def exits
      self.allocations.collect(&:simple_destinations).flatten.group_by{|x| x[:exit_type]}
    end

    def destinations
      exits["Destination"] ||= []
    end
  end

  class RouteCollection
    def initialize(rs)
      @rs = rs
      build_routes
    end


    def routes
      @routes ||= []
    end

    def routes_for(segment,label)
      r = [] 
      rows = yacc_row(segment,label)
      rows.each do |row|
        route = routes.select {|rr| rr.equal(row)}
        r.concat(route) if route
      end
      r
    end

    def deleted_routes
      routes.select{|s| s.isDelete}
    end

    private

    def build_routes
      routes.concat(@rs.build_routes)
    end

    def yacc_row(segment,label)
      segment.build_utc_segments
      values = @rs.squash(segment.utc_segments)
      out = values.map do |times, binary|
       {:day_of_week => binary, :begin_time => times[0], :end_time => times[1], :app_id => @rs.app_id, :route_name => label.vlabel, :isDelete => label.isDelete}
      end
      out
    end


  end
end
