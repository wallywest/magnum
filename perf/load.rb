require 'factory_girl'
require 'pry'
require 'magnum'
require './perf/models.rb'
require 'mongo'

FactoryGirl.find_definitions

@big_profile = netflix_profile
@small_profile = regular_profile
@simple_profile = simple_profile 

@big_profile.id = 2
@small_profile.id = 1
@simple_profile.id = 3

#conn = Mongo::Connection.new("192.168.129.223",27017)
conn = Mongo::Connection.new("localhost",27017, :logger => Logger.new(STDOUT))
@db = conn["super_profiles"]
@collection = @db["super_profiles"]

@big_profile.extend(Magnum::SPRepresenter)
@small_profile.extend(Magnum::SPRepresenter)
@simple_profile.extend(Magnum::SPRepresenter)

##@collection.insert(@small_profile.to_hash)
@collection.insert(@big_profile.to_hash)
##@collection.insert(@simple_profile.to_hash)
