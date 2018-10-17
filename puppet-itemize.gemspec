$:.unshift File.expand_path("../lib", __FILE__)
require 'puppet_x/binford2k/itemize/version'
require 'date'

Gem::Specification.new do |s|
  s.name              = "puppet-itemize"
  s.version           = Puppet_X::Binford2k::Itemize::VERSION
  s.date              = Date.today.to_s
  s.summary           = "Count the number of types, classes, functions used in Puppet manifest(s)."
  s.license           = 'Apache-2.0'
  s.email             = "ben.ford@puppet.com"
  s.homepage          = "https://github.com/binford2k/binford2k-itemize"
  s.authors           = ["Ben Ford"]
  s.require_path      = "lib"
  s.executables       = %w( puppet-itemize )
  s.files             = %w( CHANGELOG.md README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.add_dependency      "puppet", [">= 4.10", "< 7.0"]

  s.description       = <<-desc
  Run this command with a space separated list of either manifest file paths, or
  directories containing manifests. If omitted, it will default to inspecting all
  manifests in the manifests directory, so you can just run this in the root of a
  Puppet module and it will do the right thing.
  desc

end
