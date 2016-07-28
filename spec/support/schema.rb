#AR Models
class VlabelMap < ActiveRecord::Base
  self.table_name = "yacc_vlabel_map"
  self.primary_key = :vlabel_map_id
  has_many :packages
end

class Package < ActiveRecord::Base
  self.table_name = "web_packages"
  has_many :profiles
  accepts_nested_attributes_for :profiles, :allow_destroy => true
end

class Profile < ActiveRecord::Base
  self.table_name = "web_profiles"
  has_many :time_segments
  accepts_nested_attributes_for :time_segments, :allow_destroy => true
end

class TimeSegment < ActiveRecord::Base
  self.table_name = "web_time_segments"
  has_many :routings
  accepts_nested_attributes_for :routings, :allow_destroy => true
end

class Routing < ActiveRecord::Base
  self.table_name = "web_routings"
  has_many :routing_exits
  accepts_nested_attributes_for :routing_exits, :allow_destroy => true
end

class RoutingExit < ActiveRecord::Base
  self.table_name = "web_routing_destinations"
end

class RaccRoute < ActiveRecord::Base
  self.table_name = "yacc_route"
  self.primary_key = :route_id
end

class RaccRouteDestinationXref < ActiveRecord::Base
  self.table_name = "yacc_route_destination_xref"
  self.primary_key = :route_destination_xref_id
end

class Destination < ActiveRecord::Base
  self.table_name = "yacc_destination"
  self.primary_key = :destination_id
end

####SEQUEL MODELS
class DestinationSequel < Sequel::Model(:yacc_destination)
end

class VlabelMapSequel < Sequel::Model(:yacc_vlabel_map)
  primary_key = :vlabel_map_id
end

class MediaFile < Sequel::Model(:recordings)
  primary_key = :recording_id
end

class DestinationPropertySequel < Sequel::Model(:yacc_destination_property)
end

include Mongo
client = MongoClient.new('localhost',27017)
db = client["magnum-test"]
$MAGNUM_COLLECTION = db['test']
