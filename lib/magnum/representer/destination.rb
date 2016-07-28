module Magnum
  module  DestinationRepresenter
    include Representable::JSON
    property :id
    property :destination_id
    property :type
    property :requires_dequeue
    property :dequeue, :default => ""
    property :value
  end
end
