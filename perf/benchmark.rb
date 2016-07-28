require 'benchmark'
require 'pry'
require 'proto'
#require 'mysql2'
require 'arjdbc'
require 'active_record'
require 'sequel'
require 'factory_girl'
require './perf/schema.rb'
require './perf/models.rb'

FactoryGirl.find_definitions

MEGABYTE = 1024.0 * 1024.0

@big_profile = netflix_profile
@small_profile = regular_profile

Benchmark.bm do |bm|

  bm.report("#rendering in json for regular SuperProfile        ") do
    @small_profile.extend(Proto::SPRepresenter)
    @prjson = @small_profile.to_json
  end
  puts "profile size in json is: #{bytesToMeg(@prjson.size)} MB"

  bm.report("#rendering in json for large SuperProfile        ") do
    @big_profile.extend(Proto::SPRepresenter)
    @prjson = @big_profile.to_json
  end
  puts "profile size in json is: #{bytesToMeg(@prjson.size)} MB"

  #bm.report("#activate a regular SuperProfile        ") do
    #@small_profile.activate
  #end

  bm.report("#activate a large SuperProfile        ") do
    @big_profile.activate
  end
end
