#encoding: utf-8
#lib = File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)

require 'magnum_vail/version'

Gem::Specification.new do |spec|
  spec.name          = "magnum-vail"
  spec.version       = MagnumVail::VERSION
  spec.authors       = ["Justin Erny"]
  spec.email         = ["jerny@vailsys.com"]
  spec.description   = %q{It lays down MAGNUM}
  spec.summary       = %q{It lays down MAGNUM}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['{lib/**/*,spec/**/*,[A-Z]*}']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "representable", "~> 2.3.0"
  spec.add_dependency "activesupport"
  spec.add_dependency "tzinfo"
  spec.add_dependency "segment_tree"
  spec.add_dependency "sequel", '~> 4.29'
  spec.add_dependency "virtus", '~> 1.0.2'
  spec.add_dependency "range_operators"
  spec.add_dependency "activemodel"
  spec.add_dependency "active_model_serializers"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "database_cleaner", "~> 1.4.1"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency "mongo", "~> 1.10"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "multi_json"
end
