$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "text_search/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "text_search"
  s.version     = TextSearch::VERSION
  s.authors     = ["derenge"]
  s.email       = ["andrew@rigup.com"]
  s.homepage    = ""
  s.summary     = "Easy to use postgres full text search"
  s.description = "Easy to use postgres full text search"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails",                         ">= 4.2", "< 5.1"
  s.add_dependency "activesupport"

  s.add_development_dependency "pg",                "~> 1.1.4"
  s.add_development_dependency "rspec",             "~> 3.8.0"
  s.add_development_dependency "rspec-rails",       "~> 3.8.2"
  s.add_development_dependency "database_cleaner",  "~> 1.7.0"
end
