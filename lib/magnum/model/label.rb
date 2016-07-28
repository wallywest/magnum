module Magnum
  class Label < OpenStruct
  end

  class TestLabel
    include Virtus.model

    attribute :id, Integer
    attribute :vlabel, String
    attribute :description, String
  end
end
