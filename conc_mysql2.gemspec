# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: conc_mysql2 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "conc_mysql2"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Markus Weise"]
  s.date = "2015-02-04"
  s.description = ""
  s.email = "weise@stroeermobilemedia.de"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "conc_mysql2.gemspec",
    "lib/conc_mysql2.rb",
    "lib/conc_mysql2/client.rb",
    "lib/conc_mysql2/future.rb",
    "lib/conc_mysql2/pool.rb",
    "spec/conc_mysql2/client_spec.rb",
    "spec/conc_mysql2/future_spec.rb",
    "spec/conc_mysql2/pool_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/mweise/conc_mysql2"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Concurrent mysql requests using mysql2 gem."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mysql2>, ["~> 0.3.15"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<mysql2>, ["~> 0.3.15"])
      s.add_dependency(%q<rspec>, ["~> 2.14.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<mysql2>, ["~> 0.3.15"])
    s.add_dependency(%q<rspec>, ["~> 2.14.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

