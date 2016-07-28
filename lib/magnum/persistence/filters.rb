module Magnum
  class Filter
    def self.treeFilter(params)
      Sequel.expr(:route_name => params[:route_name], :app_id => params[:app_id])
    end

    def self.routeFilter(params)
      exps = []
      params[:times].each do |times|
        exps << Sequel.expr(:begin_time => times[0], :end_time => times[1])
      end
      filter = Sequel.&(
        Sequel.expr(:route_name => params[:route_name], :app_id => params[:app_id], :day_of_week => params[:days]),
        Sequel.|(*exps)
      )
      filter
    end
  end
end
