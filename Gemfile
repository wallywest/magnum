source 'http://rubygems.org'

gemspec

gem 'segment_tree'
gem 'sequel'
gem 'range_operators'
gem 'awesome_print'
# Specify your gem's dependencies in proto.gemspec
#
group :test,:development do
  platforms :ruby do
    # These require Ruby > 2.0.0
    # gem 'pry-byebug'
    # gem 'byebug'
    gem 'rspec-its'
  end
  gem "oj"
  gem 'mysql2'
  gem 'tiny_tds'
end

platforms :jruby do
  gem "activerecord-jdbc-adapter"
  gem "activerecord-jdbcmysql-adapter"
  gem 'activerecord-jdbcsqlite3-adapter'
end
