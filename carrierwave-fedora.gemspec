# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "carrierwave-fedora/version"

Gem::Specification.new do |s|
  s.name        = "carrierwave-fedora"
  s.version     = Carrierwave::Fedora::VERSION
  s.authors     = ["Jared Sartin"]
  s.email       = ["jaredsartin@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Allows CarrierWave to upload to Fedora}
  s.description = %q{Allows CarrierWave to upload to Fedora via RubyDora.}

  s.rubyforge_project = "carrierwave-fedora"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "rubydora"
end
