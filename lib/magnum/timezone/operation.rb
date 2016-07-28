module Magnum
  module TimeZone
    class Operations
      def initialize(profile,instructions)
        @profile = profile
        instructions.each do |op|
          operation = op.delete_at(0)
          self.send(operation,op)
        end
      end

      def split(params)
      end

      def merge(params)
      end

      def modify(params)
        old = params[0]
        new = @profile.squash(params[1].build_utc_segments)

        routes = @profile.labels.map(&:vlabel)
        range = @profile.squash(old.utc_segments)
        ds = $DB[:yacc_route].filter(
          :route_name => routes,
          :day_of_week => range.values,
          :begin_time => range.keys.first.min,
          :end_time => range.keys.first.last,
          :app_id => 8245
        )

        ds.update(
          :end_time => new.keys.first.last, 
          :begin_time => new.keys.first.first
        )
      end

      def create(params)
        @profile.add_segment(params.first)
        @profile.build_segment(params.first) do |routes|
          @profile.write(routes)
        end
      end

      def destroy(params)
      end

    end
  end
end
