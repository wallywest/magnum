module Magnum
module LabelRepresenter
  include Representable::JSON
  #include Representable::Coercion
  #check why this is broken

  property :id
  property :vlabel
  property :description
  property :isDelete, :default => false
end
end
