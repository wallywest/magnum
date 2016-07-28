# encoding: utf-8
require 'magnum'
require 'rails/railtie'

module MagnumVail
  class Railtie < ::Rails::Railtie
    config.to_prepare do
      begin
        sequel_pool = Rails.configuration.sequel
        Magnum::load(sequel_pool)
      rescue NoMethodError => e
        raise "Magnum requires Sequel::Pool"
      end
    end
  end
end
