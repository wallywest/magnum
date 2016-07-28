# dummy application.rb file that is used in script/rails so we can use the
# `rails generate migration` command

require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'

Bundler.require
require 'magnum'

module Magnum
  class Application < Rails::Application
  end
end
