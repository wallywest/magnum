module Magnum
  module Service
    class DeleteRoutes
      #only called from super profiles?
      
      def initialize(rs, delete_labels_flag = false)
        @rs = rs
        @delete_labels_flag = delete_labels_flag
        build_routes
      end

      def run
        return if routes.empty?
        persistence = Magnum::RoutePersistence.new(routes,filter)
        persistence.delete_routes(@delete_labels_flag)
        labels.each {|label| rs.remove_label(label)}
      end

      def build_routes
        labels.each{|label| routes << Magnum::Route.new(rs.app_id,label.vlabel,'','','','')}
      end


      def filter
        p = {:route_name => routes.map(&:route_name).uniq, :app_id => rs.app_id}
        Magnum::Filter::treeFilter(p)
      end

      def labels
        @labels ||= rs.labels.select(&:isDelete)
      end

      def routes
        @routes ||= []
      end

      def rs
        @rs
      end

    end
  end
end

 
