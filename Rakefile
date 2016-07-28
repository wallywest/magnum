require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'active_record'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

include ActiveRecord::Tasks

DatabaseTasks.env = "test"
DatabaseTasks.database_configuration = YAML.load(File.read('config/database.yml'))
DatabaseTasks.db_dir = 'db'
ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
namespace "db" do

  desc "create the db"
  task :create do
    DatabaseTasks.create_current("test")
  end

  desc "drop the db"
  task :drop do
    DatabaseTasks.drop_current("test")
  end

  desc "load schema"
  task "test:prepare" do
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    load("db/schema.rb")
  end
end

desc "Integration tests"
task :integration do
  RSpec::Core::RakeTask.new(:integration) do |t|
     t.fail_on_error = false
     t.pattern = 'spec/integration/*_spec.rb'
     t.rspec_opts = ['--profile','--color']
  end
end
