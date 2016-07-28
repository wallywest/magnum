module Magnum
  class Error < StandardError
  end
  class PersistenceError < Error
  end
  class InvalidType < Error
  end
end
