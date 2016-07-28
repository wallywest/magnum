module Magnum
  module Service
    class CreateRoutes
      ERROR_MESSAGE = "Magnum CreateRoutes service failed with error "
      def initialize(rs)
        @rs = rs
      end

      def run
        writer = Magnum::RoutePersistence.new(routes,filter)
        begin
          writer.save
          true
        rescue Magnum::PersistenceError => e
          message = ERROR_MESSAGE + e.message
          Magnum.log(message)
          false
        end
      end

      def routes
        @rs.build_routes
      end

      def filter
        Magnum::Filter::treeFilter({
          :route_name => routes.map(&:route_name).uniq,
          :app_id => @rs.app_id
        })
      end

    end
  end
end
