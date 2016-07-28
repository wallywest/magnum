module Magnum
  class Allocation < OpenStruct
    def value
      @value ||= Set.new [self.percentage,self.simple_destinations]
    end

    def equal(set)
      set.to_a == self.value.to_a
    end
    
    def hasADR?
      !self.adr.empty?
    end

    def simple_destinations
      #self.destinations
      self.destinations.map{|x| {:exit_type => x.type, :exit_id => x.destination_id}}
    end

    def add_destinations(destinations)
      destinations.each do |destination|
        a = Magnum::Destination.new(
          :destination_id => destination[:exit_id],
          :type => destination[:exit_type],
          :dequeue => destination[:dequeue_label],
          :requires_dequeue => destination[:requires_dequeue],
          :value => destination[:value])
        self.destinations << a
      end
    end

    def dequeues
      destinations.map(&:dequeue).uniq.reject(&:empty?).flatten
    end
  end
end
