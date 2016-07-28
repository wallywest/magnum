module Magnum
  class Destination
    include Virtus.model

    attribute :id, Integer
    attribute :destination_id, Integer
    attribute :type, String
    attribute :requires_dequeue, Boolean
    attribute :dequeue, String, :default => ""
    attribute :value, String
  end
end
