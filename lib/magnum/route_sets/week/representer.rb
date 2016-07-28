module Magnum
  module RouteSets
    module WeekRepresenter
      include Representable::JSON
      property :id
      property :name
      property :description
      property :app_id
      property :time_zone
      property :tree, :getter => lambda{|x| self.tree.mapping}, :setter => lambda{|val,args| self.tree = Magnum::WeekProfileTree.new(val)}
      #hash :tree
      collection :segments, extend: Magnum::SegmentRepresenter, class: Magnum::Segment
      collection :allocations, extend: Magnum::AllocationRepresenter, class: Magnum::Allocation
    end
  end
end
