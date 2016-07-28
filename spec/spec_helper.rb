require 'mongo'
require 'sequel'
require 'active_record'
require 'factory_girl'
require 'pry'
require 'rspec'
require 'rspec/its'
require 'timecop'
require 'database_cleaner'
require 'magnum'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}
Dir["./spec/shared/**/*.rb"].sort.each {|f| require f}

#MagnumTest.build_and_seed
MagnumTest.seed
RSpec.configure do |config|

  config.include MagnumTest
  config.include ProfileHelpers
  config.include MappingHelpers
  config.include RouteSetHelpers
  config.include MockRoutes

  FactoryGirl.find_definitions

  config.mock_with :rspec
  config.filter_run_excluding :exclude => true

  config.before(:suite) do
    class Company;end
  end

  config.after(:suite) do
    $MAGNUM_COLLECTION.remove()
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
