require 'yaml'
require 'logger'

file = YAML.load(File.read('config/database.yml'))

if RUBY_PLATFORM == "java"
  adapter = 'jdbcmysql'
  config = 'jdbc:mysql://localhost/magnum_test?user=root&password='
else
  adapter = "mysql2"
  #config = {:adapter => "mysql2", :host => "localhost", :database => "magnum_test", :user => "root", :password => ""}
  config = file["test"]
end

sequel_connection = Sequel.connect(config,:logger => Logger.new('test.log'), :max_connections => 2)
#$DB = Sequel.connect(config, :max_connections => 2)

Sequel::Model.db = sequel_connection

ar_connection = ActiveRecord::Base.establish_connection(
  :adapter => adapter,
  :database =>  'magnum_test'
)

include Mongo
client = MongoClient.new('localhost',27017)
db = client["magnum-test"]
$MAGNUM_COLLECTION = db['test']


DatabaseCleaner[:active_record,{:connection => ar_connection}]
strat = DatabaseCleaner[:sequel,{:connection => sequel_connection}]
strat.strategy = :truncation
