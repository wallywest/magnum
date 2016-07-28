module Magnum
  class RoutingExit
    include Virtus.model
    attribute :id, Integer
    attribute :routing_id, Integer
    attribute :call_priority, Integer, :default => 1
    attribute :exit_id, Integer
    attribute :exit_type, String 
    attribute :dequeue_label, String, :default => ""
    attribute :app_id, Integer
  end

  class Routing
    include Virtus.model
    attribute :id, Integer
    attribute :time_segment_id, Integer
    attribute :percentage, Integer
    attribute :call_center, Integer, :default => rand(Time.now.to_i)
    attribute :app_id, Integer
    attribute :routing_exits, Array

    def add_routing_exit(attribute)
      attribute["routing_id"] = self.id
      attribute["app_id"] = self.app_id
      routing_exit = Magnum::RoutingExit.new(attribute)
      self.routing_exits << routing_exit
      routing_exit
    end
  end

  class TimeSegment
    include Virtus.model
    attribute :id, Integer
    attribute :profile_id, Integer
    attribute :app_id, Integer
    attribute :start_min, String
    attribute :end_min, String
    attribute :routings, Array

    def add_routing(attribute)
      attribute["segment_id"] = self.id
      attribute["app_id"] = self.app_id
      routing = Magnum::Routing.new(attribute)
      self.routings << routing
      routing
    end

  end

  class Profile
    include Virtus.model

    attribute :id, Integer
    attribute :package_id, Integer
    attribute :app_id, Integer
    attribute :segments, Array
    attribute :name, String
    attribute :sun, Boolean
    attribute :mon, Boolean
    attribute :tue, Boolean
    attribute :wed, Boolean
    attribute :thu, Boolean
    attribute :fri, Boolean
    attribute :sat, Boolean
    attribute :name, String, default: :default_name

    def add_segment(attribute)
      attribute["profile_id"] = self.id
      attribute["app_id"] = self.app_id
      segment = Magnum::TimeSegment.new(attribute)
      self.segments << segment
      segment
    end

    def default_name
      if (sat && sun && mon && tue && wed && thu && fri)
        'All Week'
      elsif (sat && sun && !(mon || tue || wed || thu || fri))
        'Weekend'
      elsif (mon && tue && wed && thu && fri && !(sat || sun))
        'Weekday'
      else
        name_by_days_of_week
      end
    end

    private
    def name_by_days_of_week
      days_arr = []
      days_arr << 'Sunday' if sun
      days_arr << 'Monday' if mon
      days_arr << 'Tuesday' if tue
      days_arr << 'Wednesday' if wed
      days_arr << 'Thursday' if thu
      days_arr << 'Friday' if fri
      days_arr << 'Saturday' if sat
      days_arr.join(', ')
    end
  end

  class Package
    include Virtus.model
    attribute :id, Integer
    attribute :name, String
    attribute :description
    attribute :active, String
    attribute :app_id, Integer
    attribute :vlabel_map_id, String
    attribute :time_zone, String
    attribute :profiles, Array

    def add_profile(attribute)
      attribute["package_id"] = self.id
      attribute["app_id"] = self.app_id
      profile = Magnum::Profile.new(attribute)
      self.profiles << profile
      profile
    end

  end
end
