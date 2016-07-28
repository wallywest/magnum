module Magnum
module AllocationRepresenter
  include Representable::JSON
  include Representable::Coercion

  property :id
  property :percentage
  collection :destinations, extend: Magnum::DestinationRepresenter, class: Magnum::Destination

end
end
