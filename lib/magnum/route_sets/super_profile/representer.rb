module Magnum
  module RouteSets
    module SuperProfileRepresenter
      include Representable::JSON
      property :app_id
      property :status
      property :time_zone
      property :tree, :getter => lambda{|x| self.tree.mapping}, :setter => lambda{|val,args| self.tree = Magnum::SuperProfileTree.new(val)}
      collection :labels, extend: Magnum::LabelRepresenter, class: Magnum::Label
      collection :segments, extend: Magnum::SegmentRepresenter, class: Magnum::Segment
      collection :allocations, extend: Magnum::AllocationRepresenter, class: Magnum::Allocation
    end
  end
end

