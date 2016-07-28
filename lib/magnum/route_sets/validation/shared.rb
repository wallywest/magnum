
module Magnum
  module Validations

    def total_segment_days
      day_int = self.segments.map{|x| x.days.to_i(2)}.uniq.inject(0, &:|)
      if day_int != 127
        errors.add(:base,"Total segment days do not cover a week")
      end
    end

    def total_day_ranges
      groups = self.segments.group_by{|x| x.days}
      groups.each do |key,value|
        total = value.map{|x| (x.end_time.to_i - x.start_time.to_i)+1}.inject(0,&:+)
        errors.add(:base, "Ranges have to cover the entire day") if total != 1440
      end
    end

    def persisted_vlabels
      label_ids = self.labels.select{|x| !x.isDelete}.map(&:id)
      if label_ids.blank?
        errors.add(:base,"Labels do not exist")
        return
      end

      ids = VlabelMap.select(:vlabel_map_id).where(:vlabel_map_id => label_ids).map(&:vlabel_map_id).collect(&:to_s)
      if ids.sort != label_ids.sort
        errors.add(:base,"Labels do not exist")
        return
      end
    end

    def persisted_destinations
      all_destinations = self.allocations.map(&:destinations).flatten
      all_destinations.group_by(&:type).each do |type,destinations|
        result = used_destinations(type,destinations)
        unless result
          errors.add(:base,"Destinations do not exist")
          return
        end
      end
    end

    def validate_total_percentage_of_allocations
      flatten_tree = self.tree.flatten
      return if flatten_tree.blank?
      flatten_tree.each_pair do |key,allocations|
        if allocations.blank?
          errors.add(:base,"Allocations must equal 100% coverage")
          return
        end
        grouping = allocations.group_by{|x| allocations.grep(x).size}
        count = 0
        grouping.each do |num,allocation|
          a = self.find_allocation(allocation).map(&:percentage).collect(&:to_i).inject(0,:+)
          num.times { count += a}
        end

        if count != 100
          errors.add(:base,"Allocations must equal 100% coverage")
          return
        end

      end
    end

    def validate_feature_queuing_active
      company = ::Company.find(self.app_id)
      errors.add(:base,"Queuing destinations are unavailable since queuing is deactivated") unless company.queuing_active?
    end

    def validate_dequeue_route
      dequeues = self.allocations.map(&:dequeues).flatten.uniq
      return if dequeues.empty?

      errors.add(:base, 'Not a valid Dequeue Route') unless dequeues_valid?(dequeues)
    end

    private

    def used_destinations(type,destinations)
      allocated_ids = destinations.map(&:destination_id).uniq.sort
      if allocated_ids.include?(nil)
        errors.add(:base, "Destination does not exist")
        return
      end
      case type
      when "Destination"
        ids = ::Destination.where(:destination_id => allocated_ids, :app_id => self.app_id).select(:destination_id).map(&:id).sort
      when "VlabelMap"
        ids = VlabelMap.where(:vlabel_map_id => allocated_ids, :app_id => self.app_id).select(:vlabel_map_id).map(&:vlabel_map_id).sort
      when "MediaFile"
        #-1 job ids
        ###check this
        ids = MediaFile.where(:recording_id => allocated_ids,:app_id => self.app_id).select(:recording_id).map(&:recording_id).sort
      end
      return ids == allocated_ids
    end

    def dequeues_valid?(dequeues)
      valid_ids(dequeues).size == dequeues.size
    end

    def valid_ids(dequeues)
      active_ids = ActiveVlabelQuery.new(app_id, dequeues).ids
      circular_ids = CircularVlabelQuery.new(app_id, dequeues).ids
      active_ids | circular_ids
    end
  end
end
