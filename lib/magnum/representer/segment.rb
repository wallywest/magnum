module Magnum
module SegmentRepresenter
  include Representable::JSON

  property :id
  property :days
  property :start_time
  property :end_time
end
end
