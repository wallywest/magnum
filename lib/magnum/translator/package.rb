module Magnum
  class RoutingExitSerializer < ActiveModel::Serializer
    attributes :id, :exit_id, :exit_type, :call_priority, :dequeue_label, :value
    def value
      self.object.exit_object.value
    end
  end
  class RoutingSerializer < ActiveModel::Serializer
    attributes :id, :percentage
    has_many :routing_exits, serializer: Magnum::RoutingExitSerializer
  end
  class TimeSegmentSerializer < ActiveModel::Serializer
    attributes :id, :start_min, :end_min
    has_many :routings, serializer: Magnum::RoutingSerializer
  end
  class ProfileSerializer < ActiveModel::Serializer
    attributes :id, :dayString
    has_many :time_segments, serializer: Magnum::TimeSegmentSerializer

    def dayString
      days = ""
      [:sun,:mon,:tue,:wed,:thu,:fri,:sat].each do |day|
        days << (object.send(day) ? "1" : "0")
      end
      days
    end
  end
  class PackageSerializer < ActiveModel::Serializer
    attributes :id, :time_zone, :app_id, :active, :vlabel_id, :vlabel, :vlabel_map_description
    has_many :profiles, serializer: Magnum::ProfileSerializer

    def vlabel_id
      object.vlabel_map.vlabel_map_id
    end

    def vlabel
      object.vlabel_map.vlabel
    end

    def vlabel_map_description
      object.vlabel_map.description
    end
  end
end

