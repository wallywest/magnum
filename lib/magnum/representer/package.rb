module Magnum

  module RoutingExitRepresenter
    include Representable::JSON
    property :exit_type
    property :exit_id
    property :call_priority
    property :dequeue_label
    property :app_id
  end

  module RoutingRepresenter
    include Representable::JSON
    property :app_id
    property :percentage
    property :call_center
    collection :routing_exits_attributes, extend: Magnum::RoutingExitRepresenter, class: Magnum::RoutingExit, :getter => lambda{ |*| @routing_exits}
  end

  module TimeSegmentRepresenter
    include Representable::JSON
    property :app_id
    property :end_min
    property :start_min
    collection :routings_attributes, extend: Magnum::RoutingRepresenter, class: Magnum::Routing, :getter => lambda{ |*| @routings}
  end

  module ProfileRepresenter
    include Representable::JSON
    property :app_id
    property :name
    property :sun
    property :mon
    property :tue
    property :wed
    property :thu
    property :fri
    property :sat
    collection :time_segments_attributes, extend: Magnum::TimeSegmentRepresenter, class: Magnum::TimeSegment, :getter => lambda{ |*| @segments}
  end

  module PackageRepresenter
    include Representable::JSON
    property :app_id
    property :name
    property :description
    property :time_zone
    collection :profiles_attributes, extend: Magnum::ProfileRepresenter, class: Magnum::Profile, :getter => lambda { |*| @profiles }
  end
end
