module Magnum
  class ActiveVlabelQuery < Magnum::VlabelQueryBase

    def ids
      run.map{|x| x[:vlabel_map_id]}
    end

    def run
      ds.select(:yacc_vlabel_map__vlabel, :yacc_vlabel_map__vlabel_map_id, :yacc_vlabel_map__description).distinct.
        join(:yacc_op, :yacc_op__vlabel_group => replace_fn, :app_id => :app_id).
        join(:yacc_route, join_literal).
        where(:yacc_vlabel_map__app_id => app_id).
        where(:yacc_vlabel_map__vlabel => labels)
    end

    private

    def replace_fn
      Sequel.function(:REPLACE, :yacc_vlabel_map__vlabel_group, '_GEO_ROUTE_SUB', '')
    end

    def join_literal
      Sequel.&(
        Sequel.|({:yacc_route__route_name => :yacc_vlabel_map__vlabel},
                 {:yacc_route__route_name => :yacc_op__newop_rec}),
                 {:yacc_route__app_id => :yacc_vlabel_map__app_id})
    end
  end
end
