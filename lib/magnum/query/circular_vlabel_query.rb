module Magnum
  class CircularVlabelQuery < Magnum::VlabelQueryBase

    def ids
      run.map { |x| x[:vlabel_map_id] }
    end

    def run
      ds.select(:yacc_vlabel_map__vlabel, :yacc_vlabel_map__vlabel_map_id, :yacc_vlabel_map__description).distinct
        .join(:web_packages, :yacc_vlabel_map__vlabel_map_id => :web_packages__vlabel_map_id)
        .join(:web_profiles, :web_packages__id => :web_profiles__package_id)
        .join(:web_time_segments, :web_profiles__id => :web_time_segments__profile_id)
        .join(:web_routings, :web_time_segments__id => :web_routings__time_segment_id)
        .join(:web_routing_destinations, :web_routings__id => :web_routing_destinations__routing_id,
              :yacc_vlabel_map__vlabel => :web_routing_destinations__dequeue_label)
        .where(:yacc_vlabel_map__app_id => app_id)
        .where(:yacc_vlabel_map__vlabel => labels)
    end
  end
end
