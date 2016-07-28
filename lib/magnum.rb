require 'virtus'
require 'representable'
require 'representable/json'
require 'representable/coercion'
require 'json'
require 'active_support/core_ext'
require 'active_model_serializers'
require 'sequel'
require 'range_operators'

require 'magnum/extension'
require 'magnum/error'
require 'magnum/timezone'
require 'magnum/persistence'
require 'magnum/services'
require 'magnum/model'
require 'magnum/diff'
require 'magnum/translator'
require 'magnum/representer'
require 'magnum/query'
require 'magnum/route_sets'

#require 'oj'
#MultiJson.engine = :oj

module Magnum

  class << self
    def connection
      @db
    end

    def connection=(db)
      @db=db
    end

    def log=(logger)
      @logger = logger
    end

    def log(message)
      @logger.info(message)
    end

    def load(sequel_pool)
      self.log = sequel_pool.logger
      self.connection = sequel_pool.connection
    end

    def available_types
      types.keys
    end

    def build(type,json,options = {})
      begin
        klass = types[type]
        type = klass.translate(json,options)
        type
      rescue NoMethodError => e
        raise Magnum::InvalidType, e.message
      end
    end

    def convert(type,object,options = {})
      begin
        klass = types[type]
        type = klass.convert(object)
        type
      rescue NoMethodError => e
        raise Magnum::InvalidType, e.message
      end
    end

    private

    def types
      Magnum::RouteSets.types
    end
  end
end
