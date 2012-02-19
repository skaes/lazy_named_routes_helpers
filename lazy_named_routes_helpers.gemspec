# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lazy_named_routes_helpers/version"

Gem::Specification.new do |s|
  s.name        = "lazy_named_routes_helpers"
  s.version     = LazyNamedRoutesHelpers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stefan Kaes"]
  s.email       = ["skaes@railsexpress.de"]
  s.homepage    = "https://github.com/skaes/lazy_named_routes_helpers"
  s.summary     = "Generate rails helper methods for accessing named routes on demand"
  s.description = "Generate rails helper methods for accessing named routes on demand"

  s.rubyforge_project = "lazy_named_routes_helpers"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
