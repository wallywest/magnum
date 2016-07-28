ActiveRecord::Base.establish_connection(
  :adapter => 'jdbcmysql',
  :database =>  'proto_test',
  :username => 'root'
)
ActiveRecord::Migration.create_table "yacc_route", :primary_key => "route_id", :force => true do |t|
  t.integer  "app_id",                                                         :null => false
  t.string   "route_name",              :limit => 64,                          :null => false
  t.integer  "day_of_week",                                                    :null => false
  t.integer  "begin_time",                                                     :null => false
  t.integer  "end_time",                                                       :null => false
  t.string   "destid",                  :limit => 64,                          :null => false
  t.integer  "distribution_percentage",                                        :null => false
  t.datetime "created_at"
  t.datetime "updated_at"
end

ActiveRecord::Migration.create_table "yacc_route_destination_xref", :primary_key => "route_destination_xref_id", :force => true do |t|
    t.integer  "app_id",                                                   :null => false
    t.integer  "route_id",                                                 :null => false
    t.integer  "route_order",                                              :null => false
    t.integer  "destination_id",                                           :null => false
    t.string   "transfer_lookup",                                          :null => false
    t.string   "dequeue_label",   :limit => 64, :default => "",            :null => false
    t.string   "dtype",           :limit => 1,  :default => "D",           :null => false
    t.string   "exit_type",                     :default => "Destination", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
end

class RaccRoute < ActiveRecord::Base
  self.table_name = "yacc_route"
  self.primary_key = :route_id
end

class RaccRouteDestinationXref < ActiveRecord::Base
  self.table_name = "yacc_route_destination_xref"
  self.primary_key = :route_destination_xref_id
end

#db = "jdbc:sqlite:proto-test"
db = "jdbc:mysql://localhost/proto_test?user=root"
$DB = Sequel.connect(db, :max_connections => 5)
$DB.logger = ::Logger.new("query.log")

Sequel::Model.db = $DB

class RaccRouteSequel < Sequel::Model(:yacc_route)
end

class RaccRouteDestinationXrefSequel < Sequel::Model(:yacc_route_destination_xref)
end
